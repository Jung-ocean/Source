%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS initial file from SODA Data
%
%  Extrapole and interpole temperature, salinity and currents from a
%  Climatology to get initial conditions for
%  ROMS (initial netcdf files) .
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  P. Marchesiello & P. Penven - IRD 2005
%
%  Version of 21-Sep-2005
%
%  Modified by J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title
%
title='SODA3';
casename = 'EYECS';
%
% Common parameters
%
% SODA file directory
climato_dir = 'D:\Data\Ocean\Model\SODA3\';
climato_file = 'soda3.4.2_5dy_ocean_reg_2013_01_04.nc';

% ROMS initial and grid file information
ininame = ['roms_ini_', casename, '_SODA3_2013.nc']; % Initial filename to be created

g = grd(casename);
grdname = g.grd_file;
theta_s = g.theta_s; theta_b = g.theta_b;
h = g.h; hc = g.hc; N = g.N; tini = 0;
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
[M, L] = size(lon_rho);
%
%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
% In this case, monthly and annual data were treated as the same
month_data  = [climato_dir, climato_file];
ann_data    = [climato_dir, climato_file];
insitu2pot       = 0;   %1: transform in-situ temperature to potential temperature
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making initial file: ',ininame])
disp(' ')
disp([' Title: ',title])
%
% Initial file
%
vtransform = 2;
vstretching = 4;
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
create_inifile_J(ininame,grdname,title,...
    theta_s,theta_b,hc,N, tini,'clobber',vtransform);
%
% Horizontal and vertical interp/extrapolations
%
disp(' ')
disp(' Interpolations / extrapolations')
disp(' ')
disp(' Temperature...')
ext_tracers_ini_SODA_J(ininame,grdname,month_data,ann_data,...
    'temp','temp','r',tini);
disp(' ')
disp(' Salinity...')
ext_tracers_ini_SODA_J(ininame,grdname,month_data,ann_data,...
    'salt','salt','r',tini);
disp(' ')
disp(' U...')
ext_tracers_ini_SODA_J(ininame,grdname,month_data,ann_data,...
    'u','u','u',tini);
disp(' ')
disp(' V...')
ext_tracers_ini_SODA_J(ininame,grdname,month_data,ann_data,...
    'v','v','v',tini);

disp(' ')
disp(' SSH...')
nc = netcdf(month_data);
lon = nc{'xt_ocean'}(:);
lat = nc{'yt_ocean'}(:);
ssh = nc{'ssh'}(:);
missval = nc{'ssh'}.missing_value(:);
close(nc)
[lon2, lat2] = meshgrid(lon, lat);

ro = 0; default = NaN;
data = get_missing_val(lon,lat,ssh,missval,ro,default);
ssh_ROMS = griddata(lat2, lon2, data, lat_rho, lon_rho);
inc = netcdf(ininame, 'w');
inc{'zeta'}(:) = ssh_ROMS;
close(inc)

disp(' ')
disp(' Ubar and Vbar...')
barotropic_currents_J(ininame,grdname,[1 1 1 1])

%
% Geostrophy
%
%  disp(' ')
%  disp(' Compute geostrophic currents')
%  geost_currents(ininame,grdname,oaname,frcname,zref,obc,0)
%
% Initial file
%
if (insitu2pot)
    disp(' ')
    disp(' Compute potential temperature from in-situ...')
    getpot(ininame,grdname)
end
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
coastfileplot = 'm_coasts.mat';
test_clim(ininame,grdname,'temp',1, coastfileplot)
figure
test_clim(ininame,grdname,'salt',1, coastfileplot)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
