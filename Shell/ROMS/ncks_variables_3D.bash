#!/bin/bash

#variables=('salt' 'v' 'u' 'temp')
variables=('temp' 'salt')
layer=1
filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4'
filename_head='Dsm4_avg'

ind_layer=$((layer-1));

for variable in ${variables[@]}; do
  for fi in {1278..1463}; do
    ncks -C -d s_rho,${ind_layer} -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_layer_${layer}_${fi}.nc
  done
done
