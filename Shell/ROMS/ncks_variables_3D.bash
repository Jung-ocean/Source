#!/bin/bash

#variables=('salt' 'v' 'u' 'temp')
variables=('salt')
layer=45
filepath='../daily/'
filename_head='ocean_avg'

ind_layer=$((layer-1));

for variable in ${variables[@]}; do
  for fi in {0001..0366}; do
    ncks -C -d s_rho,${ind_layer} -v ${variable},ocean_time ${filepath}/${filename_head}_${fi}.nc ./${variable}_layer_${layer}_${fi}.nc
  done
done
