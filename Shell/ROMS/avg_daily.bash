#!/bin/bash

index=$(seq 244 247)
yyyy_all=$(seq 2010 2019)

filepath=/home/jhjung/Model/ROMS/EYECS/exp_HYCOM

for i in ${index}
do
  for yyyy in ${yyyy_all}
  do
    # leap year? ====================
    (( !(yyyy % 4) && ( yyyy % 100 || !(yyyy % 400) ) )) &&
    leapindex=1 || leapindex=0
    #================================
    if [ $leapindex == "0" ]
    then
      ls ${filepath}/${yyyy}/output/avg_0${i}.nc >> tmp.txt
    else
      i2=$(expr $i + 1)
      ls ${filepath}/${yyyy}/output/avg_0${i2}.nc >> tmp.txt
    fi
  done
  
  cat tmp.txt | ncra ./seasonal/avg_0${i}.nc
  rm tmp.txt
done
