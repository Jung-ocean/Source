#!/bin/bash

#variables=('salt' 'v' 'u' 'temp')
variables=('salt')
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for variable in ${variables[@]}; do
  for fi in {1371..1432}; do
    ncks -C -d s_rho,44 -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_${fi}.nc
  done
done
