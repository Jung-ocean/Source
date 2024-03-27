#!/bin/bash

start_date=20180701
runday=153

filepath_HYCOM=/data/jungjih/Models/SCHISM/test_schism/v1_SMS_min_5m_3D/gen_input/3Dth/HYCOM

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
