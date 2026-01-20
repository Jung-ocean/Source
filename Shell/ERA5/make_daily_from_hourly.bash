#!/bin/bash

# This bash shell script is to make daily average from houly ERA5
# You need to activate your conda environment and install CDO with conda
# FYI, https://code.mpimet.mpg.de/projects/cdo/wiki/Anaconda
# J. Jung

export yyyy
export mm

filepath_hourly=/data/jungjih/Models/ERA5/hourly
filepath_daily=/data/jungjih/Models/ERA5/daily

for yyyy in {2010..2025}; do
  for mm in {04..06}; do
    filename=ERA5_${yyyy}${mm}.nc
    cdo daymean ${filepath_hourly}/${filename} ${filepath_daily}/${filename}    
  done # mm
done # yyyy
