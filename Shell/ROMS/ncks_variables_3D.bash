#!/bin/bash

#variables=('salt' 'v' 'u' 'temp')
variables=('temp')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4'
filename_head='Dsm4_avg'

for variable in ${variables[@]}; do
  for fi in {0020..2006}; do
    ncks -C -d s_rho,44 -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
