#!/bin/bash

  expname='ADSEN'
  filename='ocean_ADJ.in'

  y=$1
  NLM=/home/jhjung/Model/ROMS/${expname}/exp_NLM
  ADJ=/home/jhjung/Model/ROMS/${expname}/exp_ADJ

  cp ${ADJ}/ocean_ADJ_upper.in ${ADJ}/${y}/run/${filename}

  ls ${NLM}/${y}/output/his* > ${ADJ}/hislists.txt

  lines=`wc -l ${ADJ}/hislists.txt | awk '{print $1}'`

  filelists=$(seq 1 ${lines})
  for i in $filelists
  do
    his=`head -${i} ${ADJ}/hislists.txt | tail -1`
    if [ $i == $lines ]
    then
      echo ${his} >> ${ADJ}/${y}/run/${filename}
    else
      his_with_bar="${his} |"
      echo ${his_with_bar} >> ${ADJ}/${y}/run/${filename}
    fi
  done

  cat ${ADJ}/ocean_ADJ_lower.in >> ${ADJ}/${y}/run/${filename}
  rm ${ADJ}/hislists.txt
