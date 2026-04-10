#!/bin/bash

filename_head=${1}
vari_str=${2}

# Concatenation
ncecat ${filename_head}* ./cat.nc

# Mean
ncea ${filename_head}* ./mean.nc

# Deviation
ncbo -v ${vari_str} cat.nc mean.nc ./deviation.nc

# Standard deviation (rmssdn = Root-mean square normalized by N-1)
ncra -y rmssdn deviation.nc ./std.nc
