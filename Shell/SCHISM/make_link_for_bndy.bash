#!/bin/bash

start_date=20190701
runday=153

filepath_HYCOM=/data/jungjih/Models/SCHISM/test_schism/v2_JZ/gen_input/2019/3Dth/HYCOM

for i in $(seq 1 $runday); do
  yyyy=$(date -d "$start_date $((i-1)) day" "+%Y")
  yyyymmdd=$(date -d "$start_date $((i-1)) day" "+%Y%m%d")
  
  filepath=${filepath_HYCOM}
  filename=HYCOM_${yyyymmdd}.nc
  file=${filepath}/${filename}

  ln -s ${file} ./SSH_${i}.nc
  ln -s ${file} ./TS_${i}.nc
  ln -s ${file} ./UV_${i}.nc
done 
