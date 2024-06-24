#!/bin/bash
# You need a output grid information file (e.g. ROMSgrid.txt)

for yyyy in {2019..2022}; do
  for mm in {1..4}; do
    [ $mm -lt 10 ] && mm=0$mm
    for dd in {1..31}; do
      [ $dd -lt 10 ] && dd=0$dd

      cdo remapbil,ROMSgrid.txt ./daily_polar/asi-AMSR2-n6250-${yyyy}${mm}${dd}-v5.4.nc ./daily_ROMSgrid/asi-AMSR2-n6250-${yyyy}${mm}${dd}-v5.4.nc

    done # dd
  done # mm
done # yyyy
