#!/bin/bash

filepath='/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng'
filename_head='Dsm2_spng_avg'

for fi in {0570..0620}; do
  ncks -v zeta ${filepath}/${filename_head}_${fi}.nc ./zeta_${fi}.nc
done
