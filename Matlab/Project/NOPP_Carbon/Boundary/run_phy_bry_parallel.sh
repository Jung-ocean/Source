#!/bin/bash
#
# run_phy_bry_parallel.sh
#
# Builds the physical open boundary condition file by running
# d_obc_roms2roms_Oregon_1km_LiveOcean.m as several Matlab sessions in
# parallel, each covering part of the year, then concatenating the chunks
# along 'bry_time' with ncrcat.
#
# Each day is interpolated independently of the others, so splitting the
# year into NCHUNK pieces cuts the wall time by about that factor.
#
# Usage:
#
#   ./run_phy_bry_parallel.sh [NCHUNK] [OUTDIR]
#
#     NCHUNK   number of parallel sessions   (default 8)
#     OUTDIR   directory for the final file
#              (default /data/jungjih/Project/NOPP_Carbon/Oregon_1km/
#               Setups/Boundary_LiveOcean)
#
# Each session works in OUTDIR/chunk_NN, so the sessions never write to
# the same file.  The driver names its output from the 'domain' set
# inside it, so the merge step discovers the file name rather than
# assuming one.  The merged file is written to OUTDIR and the chunk
# directories are left in place so a failed chunk can be rerun on its own
# and merged again.
#
# Unlike the biology tracers, the physical variables all live in a single
# file, so there is one merge at the end rather than one per variable.
#

set -u

NCHUNK=${1:-8}
OUTDIR=${2:-/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Setups/Boundary_LiveOcean}

NDAYS=366

MATLAB=/home/server/local/apps/matlab.2022a/bin/matlab
DRIVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR=/home/server/pi/homes/jungjih/Source/Matlab/Tools/generic

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
echo " Physical boundary conditions: $NCHUNK parallel sessions"
echo " driver : $DRIVER_DIR/d_obc_roms2roms_Oregon_1km_LiveOcean.m"
echo " output : $OUTDIR"
echo " threads: $have in use, ~$want needed, limit $(ulimit -u)"
echo "=================================================================="

#------------------------------------------------------------------
# Launch one Matlab session per chunk.
#------------------------------------------------------------------

pids=()
dirs=()

start=1
per=$(( (NDAYS + NCHUNK - 1) / NCHUNK ))

for (( c=1; c<=NCHUNK; c++ )); do
  stop=$(( start + per - 1 ))
  [ "$stop" -gt "$NDAYS" ] && stop=$NDAYS
  if [ "$start" -gt "$NDAYS" ]; then break; fi

  cdir=$(printf "chunk_%02d" "$c")
  mkdir -p "$cdir"
  dirs+=("$cdir")

  echo "  chunk $c: days ${start}-${stop}  -> $cdir"

  (
    cd "$cdir" || exit 1
    PHY_BRY_DAYS="${start}:${stop}" \
    "$MATLAB" -nodisplay -nosplash -singleCompThread -batch \
      "addpath('$TOOLS_DIR'); addpath('$DRIVER_DIR'); d_obc_roms2roms_Oregon_1km_LiveOcean" \
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
    echo "  session $((i+1)) FAILED (see ${dirs[$i]}/run.log)"
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
# Work out the output file name from what the driver produced, and
# check every chunk agrees.
#------------------------------------------------------------------

BRYFILE=""
parts=()

for d in "${dirs[@]}"; do
  n=$(ls "$d"/*.nc 2>/dev/null | wc -l)
  if [ "$n" -ne 1 ]; then
    echo "Expected exactly one .nc file in $d, found $n - not merging."
    exit 1
  fi
  f=$(ls "$d"/*.nc)
  base=$(basename "$f")
  if [ -z "$BRYFILE" ]; then
    BRYFILE="$base"
  elif [ "$BRYFILE" != "$base" ]; then
    echo "Chunk file names differ ($BRYFILE vs $base) - not merging."
    exit 1
  fi
  parts+=("$f")
done

#------------------------------------------------------------------
# Concatenate the chunks along bry_time, in day order.
#------------------------------------------------------------------

echo ""
echo "Merging ${#parts[@]} chunks into $BRYFILE ..."

if ncrcat -O -h "${parts[@]}" "$BRYFILE"; then
  nrec=$(ncdump -h "$BRYFILE" \
         | grep -oE 'bry_time = UNLIMITED[^/]*// \([0-9]+' \
         | grep -oE '[0-9]+$')
  echo "  wrote $BRYFILE ($nrec records)"
else
  echo "  ncrcat FAILED"
  exit 1
fi

echo ""
echo "Done. Merged file is $OUTDIR/$BRYFILE"
echo "Chunk directories kept; remove them once the merged file checks out."
