#!/bin/bash

filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for fi in {0580..0610}; do
  ncks -v zeta ${filepath}/${filename_head}_${fi}.nc ./zeta_${fi}.nc
done
