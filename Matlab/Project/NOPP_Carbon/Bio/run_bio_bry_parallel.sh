#!/bin/bash
#
# run_bio_bry_parallel.sh
#
# Builds the Spitz biology open boundary condition files by running
# d_obc_bio_Oregon_1km_LiveOcean.m as several MATLAB sessions in
# parallel, each covering part of the year, then concatenating the
# chunks along 'bry_time' with ncrcat.
#
# A single session takes roughly 21 hours for 366 days.  Splitting the
# year into NCHUNK pieces cuts the wall time by about that factor, since
# each day is interpolated independently of the others.
#
# Usage:
#
#   ./run_bio_bry_parallel.sh [NCHUNK] [OUTDIR]
#
#     NCHUNK   number of parallel sessions   (default 8)
#     OUTDIR   directory for the final files
#              (default /data/jungjih/Project/NOPP_Carbon/Oregon_1km/
#               Setups/Bio_LiveOcean)
#
# Each session works in OUTDIR/chunk_NN, so the sessions never write to
# the same file.  The merged files are written to OUTDIR and the chunk
# directories are left in place so a failed chunk can be rerun on its
# own and merged again.
#

set -u

NCHUNK=${1:-8}
OUTDIR=${2:-/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Setups/Bio_LiveOcean}

NDAYS=366
DOMAIN=Oregon_1km
PREFIX="boundary_${DOMAIN}_bio_"

MATLAB=/home/server/local/apps/matlab.2022a/bin/matlab
DRIVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR=/home/server/pi/homes/jungjih/Source/Matlab/Tools/generic

BIOVARS="NO3 NH4 DON DetN Bacteria Phytoplankton Microzooplankton \
Chlorophyll DetC DOC Mesozooplankton Silica Diatoms LDetN LDetC LDetS ChlD"

mkdir -p "$OUTDIR"
cd "$OUTDIR" || exit 1

#------------------------------------------------------------------
# Thread budget.  Each Matlab session spawns dozens of threads (JVM
# garbage collector, BLAS pool, I/O).  Exceeding the per-user limit
# makes the JVM fail with "Cannot create GC thread. Out of system
# resources." and Matlab aborts, which the shell reports as "Killed".
#
# The sessions are started with -singleCompThread so each uses one
# computational thread instead of sizing its BLAS pool to every core:
# the parallelism here comes from the chunks, not from inside Matlab.
#------------------------------------------------------------------

THREADS_PER_SESSION=60          # generous allowance per Matlab session

want=$(( NCHUNK * THREADS_PER_SESSION ))
have=$(ps -eLf -u "$USER" 2>/dev/null | wc -l)
lim=$(ulimit -u)

if [ "$lim" != "unlimited" ] && [ $(( have + want )) -gt "$lim" ]; then
  hard=$(ulimit -Hu)
  need=$(( have + want ))
  if [ "$hard" = "unlimited" ] || [ "$need" -le "$hard" ]; then
    ulimit -u "$need" 2>/dev/null && \
      echo "Raised thread limit: $lim -> $(ulimit -u)"
  fi
  lim=$(ulimit -u)
  if [ "$lim" != "unlimited" ] && [ $(( have + want )) -gt "$lim" ]; then
    echo "ERROR: not enough thread headroom."
    echo "  in use=$have  needed=$want  limit=$lim  (hard=$hard)"
    echo "  Run 'ulimit -u $(( have + want ))' before this script, or use fewer chunks."
    exit 1
  fi
fi

echo "=================================================================="
echo " Biology boundary conditions: $NCHUNK parallel sessions"
echo " driver : $DRIVER_DIR/d_obc_bio_Oregon_1km_LiveOcean.m"
echo " output : $OUTDIR"
echo " threads: $have in use, ~$want needed, limit $(ulimit -u)"
echo "=================================================================="

#------------------------------------------------------------------
# Launch one MATLAB session per chunk.
#------------------------------------------------------------------

pids=()
ranges=()

start=1
per=$(( (NDAYS + NCHUNK - 1) / NCHUNK ))

for (( c=1; c<=NCHUNK; c++ )); do
  stop=$(( start + per - 1 ))
  [ "$stop" -gt "$NDAYS" ] && stop=$NDAYS
  if [ "$start" -gt "$NDAYS" ]; then break; fi

  cdir=$(printf "chunk_%02d" "$c")
  mkdir -p "$cdir"
  ranges+=("$cdir:$start:$stop")

  echo "  chunk $c: days ${start}-${stop}  -> $cdir"

  (
    cd "$cdir" || exit 1
    BIO_BRY_DAYS="${start}:${stop}" \
    BIO_BRY_CREATE=1 \
    BIO_BRY_OUTDIR="$OUTDIR/$cdir" \
    "$MATLAB" -nodisplay -nosplash -singleCompThread -batch \
      "addpath('$TOOLS_DIR'); addpath('$DRIVER_DIR'); d_obc_bio_Oregon_1km_LiveOcean" \
      > run.log 2>&1
  ) &
  pids+=($!)

  start=$(( stop + 1 ))
done

echo ""
echo "Waiting for ${#pids[@]} sessions ..."

fail=0
for i in "${!pids[@]}"; do
  if wait "${pids[$i]}"; then
    echo "  session $((i+1)) finished"
  else
    echo "  session $((i+1)) FAILED (see ${ranges[$i]%%:*}/run.log)"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo ""
  echo "One or more sessions failed; not merging. Fix and rerun those"
  echo "chunks, then rerun this script's merge step."
  exit 1
fi

#------------------------------------------------------------------
# Concatenate the chunks along bry_time, in day order.
#------------------------------------------------------------------

echo ""
echo "Merging chunks with ncrcat ..."

for v in $BIOVARS; do
  parts=()
  for r in "${ranges[@]}"; do
    d="${r%%:*}"
    f="$d/${PREFIX}${v}.nc"
    if [ ! -f "$f" ]; then
      echo "  MISSING $f - aborting merge for $v"
      parts=()
      break
    fi
    parts+=("$f")
  done

  [ "${#parts[@]}" -eq 0 ] && continue

  ncrcat -O -h "${parts[@]}" "${PREFIX}${v}.nc" \
    && echo "  wrote ${PREFIX}${v}.nc ($(ncdump -h "${PREFIX}${v}.nc" \
         | grep -oE 'bry_time = UNLIMITED[^/]*// \([0-9]+' \
         | grep -oE '[0-9]+$') records)" \
    || echo "  ncrcat FAILED for $v"
done

echo ""
echo "Done. Merged files are in $OUTDIR"
echo "Chunk directories kept; remove them once the merged files check out."
