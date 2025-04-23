#!/bin/bash

yyyy=2025
mm_all=$(echo {01..01})
dd_all=$(echo {01..01})
HHH_all=$(echo {001..024})

for mi in ${mm_all[@]}; do
  mm=${mi}
for di in ${dd_all[@]}; do
  dd=${di}
for Hi in ${HHH_all[@]}; do
  HHH=${Hi}

  filename=wcofs.t03z.${yyyy}${mm}${dd}.2ds.n${HHH}.nc
  if ! [ -e ./${yyyy}/${filename} ]; then
    wget -r -np -nd -R "index.html" https://noaa-nos-ofs-pds.s3.amazonaws.com/wcofs/netcdf/${yyyy}/${mm}/${dd}/${filename} -P ./${yyyy}/
  fi

done
done
done
