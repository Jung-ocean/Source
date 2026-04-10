#!/bin/bash

yyyy_all=$(echo {2022..2025})

for yi in ${yyyy_all[@]}; do
  yyyy=${yi}
  mkdir ./6h/${yyyy}

  wget -r -np -nd -R "index.html*" -A "*.nc" https://www.ncei.noaa.gov/data/oceans/aoml/gdp/${yyyy}/ -P ./6h/${yyyy}/

done

