#!/bin/bash

yyyy=2024
mm_all=$(echo {09..12})
dd_all=$(echo {01..31})

for mi in ${mm_all[@]}; do
  mm=${mi}
for di in ${dd_all[@]}; do
  dd=${di}

  #filename=nos.wcofs.avg.nowcast.${yyyy}${mm}${dd}.t03z.nc
  filename=wcofs.t03z.${yyyy}${mm}${dd}.avg.nowcast.nc
  if ! [ -e ./daily_3D/${filename} ]; then
    wget -r -np -nd -R "index.html" https://noaa-nos-ofs-pds.s3.amazonaws.com/wcofs/netcdf/${yyyy}${mm}/${filename} -P ./daily_3D/
  fi

done
done
