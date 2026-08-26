#!/bin/bash

#variables=('zeta' 'sustr' 'svstr' 'uice' 'vice' 'tau_iw' 'ubar' 'vbar' 'aice')
variables=('zeta')
filepath='../daily'
filename_head='ocean_avg'

for variable in ${variables[@]}; do
  for fi in {0001..0366}; do
    ncks -O -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
