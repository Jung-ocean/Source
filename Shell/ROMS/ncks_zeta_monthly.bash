#!/bin/bash

filepath='./'
filename_head='Dsm4_mk2'

for yi in {2019..2023}; do
  yyyy=${yi}
for mi in {01..12}; do
  mm=${mi}
  ncks -C -v zeta,ocean_time ${filepath}/${filename_head}_${yi}${mi}.nc ./zeta_${yi}${mi}.nc
done
done
