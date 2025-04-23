#!/bin/bash

yyyy_all=$(echo {2023..2024})
mm_all=$(echo {01..12})

for yi in ${yyyy_all[@]}; do
  yyyy=${yi}
for mi in ${mm_all[@]}; do
  mm=${mi}

  wget -r -np -nd -R "index.html*" -A "*6km*" https://www.ncei.noaa.gov/data/oceans/ndbc/hfradar/rtv/${yyyy}/${yyyy}${mm}/USWC/ -P ./hourly_6km/

done
done

