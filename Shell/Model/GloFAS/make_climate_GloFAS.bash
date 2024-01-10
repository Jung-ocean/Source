#!/bin/bash

export mm

for mm in {01..12}; do
  find ../ -name *_${mm}.nc | xargs -I {} ln -s {} .
  cdo ydaymean -cat '*_${mm}.nc' tmp.nc
  rm -f *_${mm}.nc
  if [ "${mm}" -eq 02 ]; then
    cdo -del29feb tmp.nc BSf_GloFas_9999_${mm}.nc
    echo Removing 29th of February
    rm -f tmp.nc
  else
    mv tmp.nc BSf_GloFas_9999_${mm}.nc
  fi
done # mm
