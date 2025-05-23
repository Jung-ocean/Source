#!/bin/bash

casename='control'

ncks -C -d nSCHISM_vgrid_layers,50 -v temperature ../outputs_${casename}/temperature_1.nc ./temperature_surf_1.nc

for i in {7..63..7}; do
    ncks -C -d nSCHISM_vgrid_layers,50 -v temperature ../outputs_${casename}/temperature_${i}.nc ./temperature_surf_${i}.nc
done

ncra ../outputs_${casename}/out2d_{1..31}.nc ./out2d_201807.nc
ncra ../outputs_${casename}/out2d_{32..62}.nc ./out2d_201808.nc
ncks -C -v elevation ./out2d_201807.nc ./elevation_201807.nc
ncks -C -v elevation ./out2d_201808.nc ./elevation_201808.nc
ncra ../outputs_${casename}/temperature_{1..31}.nc ./temperature_201807.nc
ncra ../outputs_${casename}/temperature_{32..62}.nc ./temperature_201808.nc
ncks -C -d nSCHISM_vgrid_layers,50 -v temperature ./temperature_201807.nc ./temperature_201807_surf.nc
ncks -C -d nSCHISM_vgrid_layers,50 -v temperature ./temperature_201808.nc ./temperature_201808_surf.nc
