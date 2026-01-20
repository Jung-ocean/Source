#!/bin/bash
# You need a output grid information file (e.g. ROMSgrid.txt)

export yyyy
export mm

for yyyy in {2012..2012}; do
  for mm in {6..6}; do

    [ $mm -lt 10 ] && mm=0$mm
    cdo remapbil,ROMSgrid.txt ./monthly_polar/asi-SSMIS17-n6250-${yyyy}${mm}-v5.nc ./monthly_ROMSgrid/asi-SSMIS17-n6250-${yyyy}${mm}-v5.nc

  done # mm
done # yyyy
