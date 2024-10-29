from datetime import datetime, timedelta
import numpy as np
import roms2schism as r2s

# read SCHISM grid:
schism = r2s.schism.schism_grid()

# set up dates corresponding to ROMS files to be read:
start_date = datetime(2019, 6, 29, 12)

roms_dir = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2018/Dsm4_phi3m1/Output/'
roms_data_filename = 'Winter_2018_Dsm4_phi3m1_his_0364.nc'
dcrit = 2.1e3 # should be slightly larger than ROMS grid resolution

# create hotstart.nc file:
r2s.hotstart.make_hotstart(schism, roms_data_filename, start_date,
                           roms_dir = roms_dir, dcrit = dcrit)