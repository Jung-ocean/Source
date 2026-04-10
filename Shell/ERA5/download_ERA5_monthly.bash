#!/bin/bash

# This bash shell script is executed with the download_ERA5_monthly.py
# You need to activate your conda environment and install CDO with conda
# FYI, https://code.mpimet.mpg.de/projects/cdo/wiki/Anaconda
# J. Jung

export yyyy
export mm

for yyyy in {1979..1995}; do
#  if [ ! -d "${yyyy}" ]; then
#    mkdir ${yyyy}
#  fi
  for mm in {03..05}; do
    python download_ERA5_monthly.py
    grib_to_netcdf tmp.grib -o ./monthly/ERA5_${yyyy}${mm}.nc
    rm -f tmp.grib
  done # mm
done # yyyy
