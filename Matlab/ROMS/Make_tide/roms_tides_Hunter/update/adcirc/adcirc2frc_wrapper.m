

addpath /home/hunter/roms/tides/t_tide_v1.3beta

gfile='espresso_grid_c05.nc'
base_date=datenum(2006,1,1);
pred_date=datenum(2006,1,1);

ofile='tidetest_adcirc.nc';

adcirc2frc_v5(gfile,base_date,pred_date,ofile,1,'ESPRESSO')