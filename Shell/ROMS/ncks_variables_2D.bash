#!/bin/bash

#variables=('zeta' 'sustr' 'svstr' 'uice' 'vice' 'tau_iw' 'ubar' 'vbar' 'aice')
variables=('zeta')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4'
filename_head='Dsm4_avg'

for variable in ${variables[@]}; do
  for fi in {0579..0610}; do
    ncks -O -v ${variable} ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
