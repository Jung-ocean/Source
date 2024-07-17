#!/bin/bash

#variables=('zeta' 'sustr' 'svstr' 'uice' 'vice' 'tau_iw' 'ubar' 'vbar' 'aice')
variables=('zeta' 'svstr' 'tau_iw' 'aice')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for variable in ${variables[@]}; do
  for fi in {0517..0729}; do
    ncks -O -v ${variable} ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
