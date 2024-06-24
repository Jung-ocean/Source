#!/bin/bash

filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for fi in {1159..1188}; do
  ncks -C -d s_rho,44 -v salt,ocean_time ${filepath}/${filename_head}_${fi}.nc ./salt_${fi}.nc
done
