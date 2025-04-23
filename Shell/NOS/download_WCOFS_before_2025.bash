#!/bin/bash

yyyy=2022
mm_all=$(echo {12..12})
dd_all=$(echo {31..31})
HHH_all=$(echo {001..024})

for mi in ${mm_all[@]}; do
  mm=${mi}
for di in ${dd_all[@]}; do
  dd=${di}
for Hi in ${HHH_all[@]}; do
  HHH=${Hi}

  filename=nos.wcofs.2ds.n${HHH}.${yyyy}${mm}${dd}.t03z.nc
#   filename=nos.wcofs.avg.nowcast.${yyyy}${mm}${dd}.t03z.nc
   if ! [ -e ./${yyyy}/${filename} ]; then
     wget -r -np -nd -R "index.html" https://noaa-nos-ofs-pds.s3.amazonaws.com/wcofs/netcdf/${yyyy}${mm}/${filename} -P ./${yyyy}/
   fi

done
done
done
