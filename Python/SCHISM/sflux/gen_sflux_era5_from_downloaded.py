from datetime import datetime, timedelta
from time import time
import netCDF4 as nc4
from netCDF4 import Dataset
import pathlib
import numpy as np
import pandas as pd

from pyschism.forcing.nws.nws2.era5 import ERA5, ERA5DataInventory_downloaded, put_sflux_fields_3h

from pyschism.mesh.hgrid import Hgrid

if __name__ == '__main__':

    hgrid=Hgrid.open('../../hgrid.gr3',crs='EPSG:4326')
    bbox = hgrid.get_bbox('EPSG:4326', output_type='bbox')    

    filepath_all = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/ERA5/'

    start_date=datetime(2019, 7, 1)
    rnday=153
  
    outdir = pathlib.Path('./')
    interval = 3  
  
    air=True   #sflux_air_1
    rad=True   #sflux_rad_1
    prc=True   #sflux_prc_1
      
    # end_date=start_date+timedelta(rnday + 1)
    end_date=start_date+timedelta(rnday + 2) # +1 more day
 
    dates = {_: None for _ in np.arange(
        start_date,
        end_date,
        np.timedelta64(1, 'D'),
        dtype='datetime64')}

    ystr = str(start_date.year);
    mstr = '%02d' % start_date.month;
    filepath = filepath_all + ystr + '/'
    # filename = 'ERA5_' + ystr + '_' + mstr + '_a.nc'
    # era5file = filepath + filename
    
    # er=ERA5()
    # inventory = ERA5DataInventory_downloaded(
    #     era5file,
    #     start_date,
    #     rnday,
    #     bbox,
    #     tmpdir = outdir
    #     )
        
    # nx_grid, ny_grid = inventory.xy_grid()
        
    # ds=Dataset(inventory.files[0])
    # time1=ds['time']
    # times=nc4.num2date(time1,units=time1.units,only_use_cftime_datetimes=False)
        
    for iday, date in enumerate(dates):
        
        mstr = '%02d' % date.astype('object').month
        filename = 'ERA5_' + ystr + '_' + mstr + '_a.nc'
        era5file = filepath + filename
        
        # Load raw forcing file
        er=ERA5()
        inventory = ERA5DataInventory_downloaded(
            era5file,
            start_date,
            rnday,
            bbox,
            tmpdir = outdir
            )
            
        nx_grid, ny_grid = inventory.xy_grid()
        nx_grid = nx_grid + 360
            
        ds=Dataset(era5file)
        time1=ds['time']
        times=nc4.num2date(time1,units=time1.units,only_use_cftime_datetimes=False)
        
        # Make forcing file for SCHISM
        put_sflux_fields_3h(iday, date, times, ds, nx_grid, ny_grid, air=air, rad=rad, prc=prc, output_interval=interval, OUTDIR=outdir)
   
    #write sflux_inputs.txt
    with open("./sflux_inputs.txt", "w") as f:
        f.write("&sflux_inputs\n/\n")
