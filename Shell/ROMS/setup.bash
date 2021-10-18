#!/bin/bash

  expname='exp_01'

  y=$1
  T=/home/jhjung/Model/ROMS/YECS/${expname}
  S=/home/jhjung/Model/ROMS/YECS
  INPUT=/data2/jhjung/Model/ROMS/YECS/input

  mkdir ${T}/${y}
  mkdir ${T}/${y}/input
 
  ln -s ${INPUT}/roms_grd_auto_rdrg2_6e_4.nc ${T}/${y}/input/
  ln -s ${INPUT}/*${y}* ${T}/${y}/input
  
  mkdir ${T}/${y}/run
#  cp -r ${S}/setup_exp_01/External ${T}/${y}/run/
  ln -s ${S}/setup_${expname}/ocean_YECS_${expname} ${T}/${y}/run/

# leap year? ====================
(( !(y % 4) && ( y % 100 || !(y % 400) ) )) &&
leapindex=1 || leapindex=0
#================================
  if [ $leapindex == "0" ]
  then
    sed 's/'9999'/'"${y}"'/g' ${S}/setup_${expname}/sample.in > ${T}/${y}/run/ocean.in
  else
    sed 's/'9999'/'"${y}"'/g' ${S}/setup_${expname}/sample.in > ${T}/${y}/run/tmp.in
    sed 's/'525600'/'527040'/g' ${T}/${y}/run/tmp.in > ${T}/${y}/run/ocean.in
    rm ${T}/${y}/run/tmp.in
  fi
  sed 's/'9999'/'"${y}"'/g' ${S}/setup_${expname}/samplerun.pbs > ${T}/${y}/run/runscript.pbs
 
  mkdir ${T}/${y}/output

