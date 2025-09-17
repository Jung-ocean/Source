#!/bin/bash

gliders=( \
'ce_1012-20230317T2111' 'ce_1012-20230810T1747' 'ce_1012-20231213T1946' 'ce_1012-20240501T2126' \
'ce_1135-20250520T1953' \
'ce_1136-20240404T2140' 'ce_1136-20250404T1814' \
'ce_1137-20241004T2311' \
'ce_1153-20240501T2005' 'ce_1153-20250128T2007' \
) 

echo ${gliders[@]}
asdf
for glider in ${gliders[@]}; do
  wget https://gliders.ioos.us/erddap/tabledap/${glider}.csvp 
done
