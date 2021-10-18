#!/bin/bash

expname='exp_01'

exp_path='/home/jhjung/Model/ROMS/YECS/'${expname}

yyyy=2010
yyyy_end=2016
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
  ~/Source/Shell/Utility/Copy_ini/copy_ini_avg/copy2ROMSini

  yyyy=$(expr $yyyy + 1)
  /home/jhjung/Model/ROMS/YECS/setup_${expname}.bash $yyyy

#  cp spinup_ini.nc ${exp_path}/${yyyy}/input/roms_ini_EYECS_exp_exp_path_${yyyy}.nc
   ncatted -a units,ocean_time,o,c,'seconds since '${yyyy}'-01-01 00:00:00' spinup_ini.nc ${exp_path}/${yyyy}/input/roms_ini_YECS_${expname}_${yyyy}.nc

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
