#!/bin/bash

index=1
spinup=1

while [ $index == "1" ]
  do
    grep -s WRT_AVG ./output/log.log > check_run
    lines=`wc -l check_run | awk '{print $1}'`
    if [ $lines == "366" ] # the number of avg files
    then
      sleep 10
      mv output ./output_0$spinup
      mkdir output
      cd ./output_0$spinup
      copy2ROMSini
      mv spinup_ini.nc ../input/
      cd ..
      qsub run/runscript.pbs

      rm -f check_run
      spinup=$(expr $spinup + 1)
    else
      sleep 300
    fi

    if [ $spinup == "5" ]
    then
      index=2
    fi
 done
