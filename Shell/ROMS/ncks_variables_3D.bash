#!/bin/bash

#variables=('salt' 'v' 'u' 'temp')
variables=('salt')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4'
filename_head='Dsm4_avg'

for variable in ${variables[@]}; do
  for fi in {0184..0274}; do
    ncks -C -d s_rho,44 -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
