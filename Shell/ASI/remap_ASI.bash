#!/bin/bash
# You need a output grid information file (e.g. ROMSgrid.txt)

export yyyy
export mm

for yyyy in {2022..2022}; do
  for mm in {3..3}; do

    [ $mm -lt 10 ] && mm=0$mm
    cdo remapbil,ROMSgrid.txt ./monthly_polar/asi-AMSR2-n6250-${yyyy}${mm}-v5.4.nc ./monthly_ROMSgrid/asi-AMSR2-n6250-${yyyy}${mm}-v5.4.nc

  done # mm
done # yyyy
