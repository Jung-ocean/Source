#!/bin/bash

#variables=('zeta' 'sustr' 'svstr' 'uice' 'vice' 'tau_iw' 'ubar' 'vbar' 'aice')
variables=('aice' 'zeta')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for variable in ${variables[@]}; do
  for fi in {1281..1371}; do
    ncks -v ${variable} ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
