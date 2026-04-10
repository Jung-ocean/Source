#!/bin/bash

filename_head=${1}
vari_str=${2}

# Concatenation
ncrcat ${filename_head}* ./cat.nc

# Mean
ncra ${filename_head}* ./mean.nc

# Get rid of the time dimension of size 1 that ncra left
ncwa -O -a ocean_time mean.nc ./mean.nc

# Deviation
ncbo -v ${vari_str} cat.nc mean.nc ./deviation.nc

# Standard deviation (rmssdn = Root-mean square normalized by N-1)
ncra -y rmssdn deviation.nc ./std.nc
