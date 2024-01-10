#!/bin/bash

# This bash shell script is executed with the download_GloFAS.py
# You need to activate your conda environment and install CDO with conda
# FYI, https://code.mpimet.mpg.de/projects/cdo/wiki/Anaconda
# J. Jung

export yyyy
export mm

for yyyy in {1979..2023}; do
  if [ ! -d "${yyyy}" ]; then
    mkdir ${yyyy}
  fi
  for mm in {1..12}; do
    python download_GloFAS.py
  done # mm
  # Convert grib to nc
  for filename in ${yyyy}/*.grib; do
    cdo -f nc copy ${filename} ${filename%%.*}.nc
  done # filename grib
  # Collect horizontal grid
  for filename in ${yyyy}/*_E.nc; do
    cdo collgrid ${filename%_*}*.nc ${filename%_*}.nc
  done # filename *_E.nc
  rm -f ${yyyy}/*_E.nc ${yyyy}/*_W.nc
done # yyyy
