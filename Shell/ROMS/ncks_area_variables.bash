#!/bin/bash

filepath='../Dsm2_spng_dia'
filename_head='Winter_2020_Dsm2_spng'

for fi in {1033..1094}; do
  ncks -d eta_rho,605,956 -d xi_rho,622,1069 -v s_rho,Vtransform,Vstretching,theta_s,theta_b,Tcline,ocean_time,zeta,salt ${filepath}/${filename_head}_his_${fi}.nc ./${filename_head}_his_${fi}.nc
  ncks -d eta_rho,605,956 -d xi_rho,622,1069 -v ocean_time,zeta,salt,Huon,Hvom,ssflux,evaporation,rain,aice ${filepath}/${filename_head}_avg_${fi}.nc ./${filename_head}_avg_${fi}.nc
  ncks -d eta_rho,605,956 -d xi_rho,622,1069 -v salt_hdiff,salt_vdiff,salt_hadv ${filepath}/${filename_head}_dia_${fi}.nc ./${filename_head}_dia_${fi}.nc
done
