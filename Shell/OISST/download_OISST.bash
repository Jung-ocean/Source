#!/bin/bash

yyyy=2024
mm_all=$(echo {01..12})

for mi in ${mm_all[@]}; do
  mm=${mi}

    wget -r -np -nd -R "index.html*" https://www.ncei.noaa.gov/data/sea-surface-temperature-optimum-interpolation/v2.1/access/avhrr/${yyyy}${mm}/ -P ./daily/

done
