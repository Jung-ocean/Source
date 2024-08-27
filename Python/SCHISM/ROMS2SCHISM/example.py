from datetime import datetime, timedelta
import numpy as np
import roms2schism as r2s

# set up dates corresponding to ROMS files to be read:
start_filedate = datetime(2017, 1, 1)
ndays = 30
dates = start_filedate + np.arange(ndays) * timedelta(days = 1)
start_date = datetime(2017, 1, 12)

roms_dir = '/path/to/roms/data/'
dcrit = 7e3 # should be slightly larger than ROMS grid resolution

# read SCHISM grid:
schism = r2s.schism.schism_grid()

# create boundary forcing files:
template = "foo_his_%Y%m%d.nc"
r2s.boundary.make_boundary(schism, template, dates, start_date,
                           roms_dir = roms_dir, dcrit = dcrit)

# create boundary nudging files for T, S:
template = "foo_avg_%Y%m%d.nc"
r2s.nudging.make_nudging(schism, template, dates, start_date,
                         roms_dir = roms_dir, dcrit = dcrit)

# create hotstart.nc file:
roms_data_filename = "foo_his_20170101.nc"
r2s.hotstart.make_hotstart(schism, roms_data_filename, start_date,
                           roms_dir = roms_dir, dcrit = dcrit)

