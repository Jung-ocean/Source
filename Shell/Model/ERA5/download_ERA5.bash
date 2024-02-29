#!/bin/bash

# This bash shell script is executed with the download_ERA5.py
# You need to activate your conda environment and install CDO with conda
# FYI, https://code.mpimet.mpg.de/projects/cdo/wiki/Anaconda
# J. Jung

export yyyy
export mm

for yyyy in {2018..2020}; do
#  if [ ! -d "${yyyy}" ]; then
#    mkdir ${yyyy}
#  fi
  for mm in {1..12}; do
    python download_ERA5.py
  done # mm
done # yyyy
