#!/bin/bash

yyyy=2019

ncra ./elevation_{1..31}.nc ./elevation_${yyyy}07.nc
ncra ./elevation_{32..62}.nc ./elevation_${yyyy}08.nc
ncra ./elevation_{63..92}.nc ./elevation_${yyyy}09.nc
ncra ./elevation_{93..123}.nc ./elevation_${yyyy}10.nc
ncra ./elevation_{124..153}.nc ./elevation_${yyyy}11.nc

ncra ./temperature_surf_{1..31}.nc ./temperature_surf_${yyyy}07.nc
ncra ./temperature_surf_{32..62}.nc ./temperature_surf_${yyyy}08.nc
ncra ./temperature_surf_{63..92}.nc ./temperature_surf_${yyyy}09.nc
ncra ./temperature_surf_{93..123}.nc ./temperature_surf_${yyyy}10.nc
ncra ./temperature_surf_{124..153}.nc ./temperature_surf_${yyyy}11.nc
