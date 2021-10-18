#!/bin/bash

expname='exp_NLM'

exp_path='/home/jhjung/Model/ROMS/ADSEN/'${expname}

yyyy=2008
yyyy_end=2015
index=1

while [ $index == "1" ]
  do

# leap year? ====================
(( !(yyyy % 4) && ( yyyy % 100 || !(yyyy % 400) ) )) &&
leapindex=1 || leapindex=0
#================================
if [ $leapindex == "0" ]
then
  endday=365
else
  endday=366
fi

ls ${exp_path}/${yyyy}/output/avg* > check_run
lines=`wc -l check_run | awk '{print $1}'`
if [ $lines == $endday ] # the number of avg files
then
  sleep 20
  rm -f check_run

  cd ${exp_path}/${yyyy}/output/
#  ~/Source/Fortran/ROMS/Copy_ini/copy_ini_avg/copy2ROMSini

  yyyy=$(expr $yyyy + 1)
  /home/jhjung/Model/ROMS/ADSEN/setup_${expname}.bash $yyyy

#  cp spinup_ini.nc ${exp_path}/${yyyy}/input/roms_ini_EYECS_exp_exp_path_${yyyy}.nc
#   ncatted -a units,ocean_time,o,c,'seconds since '${yyyy}'-01-01 00:00:00' spinup_ini.nc ${exp_path}/${yyyy}/input/roms_ini_YECS_${expname}_${yyyy}.nc
  cp rst.nc ./rst_for_${yyyy}.nc

  ot1=`ncdump rst_for_${yyyy}.nc -v ocean_time | grep ocean_time | tail -1 | awk '{{ gsub(",",""); print $3 }}'`
  ot2=`ncdump rst_for_${yyyy}.nc -v ocean_time | grep ocean_time | tail -1 | awk '{{ gsub(",",""); print $4 }}'`
  
  if [ $ot1 -gt $ot2 ]
  then
    ncks -O --msa_usr_rdr -d ocean_time,0,0 rst_for_${yyyy}.nc rst_for_${yyyy}.nc
  else
    ncks -O --msa_usr_rdr -d ocean_time,1,1 rst_for_${yyyy}.nc rst_for_${yyyy}.nc
  fi

  mv rst_for_${yyyy}.nc ${exp_path}/${yyyy}/input/
  
  ls -d -1 "$PWD/"his_* | tail -1 | xargs -I {} ln -s {} ${exp_path}/${yyyy}/output/

  cd ${exp_path}/${yyyy}/run

  qsub runscript.pbs

  cd ${exp_path}

else
  sleep 300
fi # $lines == $endday

if [ $yyyy == $yyyy_end ]
then
  index=2
fi

done # while
