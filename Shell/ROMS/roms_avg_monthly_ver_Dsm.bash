#!/bin/bash
year=2022
startnum=1281
filepath='/u/jjung18/BSf/Output/Ice/Winter_2021/Dsm4_nKC_s7b3'
filename_head='Winter_2021_Dsm4_nKC_avg'
output_head='Dsm4'

(( !(year % 4) && ( year % 100 || !(year % 400) ) )) &&
leapindex=1 || leapindex=0

months=('01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12')
eomdays=('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')
if [ $leapindex == "1" ]
then
  eomdays[1]='29'
fi

mi=0
for i in ${eomdays[@]}; do
  filenum=$(printf "%04i" ${startnum})
  ncra -n ${i},4,1 ${filepath}/${filename_head}_${filenum}.nc ${output_head}_${year}${months[mi]}.nc

  mi=$((mi+1))
  startnum=$((startnum+i))
done
