#!/bin/bash

yyyy_all=$(echo {2023..2024})
stations=('46015' '46229' '46283' '46097' '46050' '46278' '46243' '46029' '46248' '46211' '46099' '46100' '46041' '46022', '46244' '46027' '46087')

for yyyy in ${yyyy_all[@]}; do
for station in ${stations[@]}; do

wget https://www.ndbc.noaa.gov/data/historical/stdmet/${station}h${yyyy}.txt.gz
wget https://www.ndbc.noaa.gov/data/historical/ocean/${station}o${yyyy}.txt.gz

done
done

gzip -d *.gz
