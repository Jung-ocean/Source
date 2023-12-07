%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS initial file from HYCOM Data
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

year = 2012; ystr = num2str(year);

%
%  Title
%
title='HYCOM';
%
% Common parameters
%
% HYCOM file directory
climato_dir = 'F:\data_HYCOM_2001-2017\';

% % In order to get FillValue_
% rawfile = [climato_dir, 'archv.2013_001_00_3zt.nc'];
% rawnc = netcdf(rawfile);
% missval = rawnc{'temperature'}.FillValue_(:);

% ROMS initial and grid file information
ininame = ['roms_ini_EYECS_HYCOM_', ystr, '.nc']; % Initial filename to be created

g = grd('EYECS');
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
month_data  = [climato_dir,'HYCOM_', ystr, '01.nc'];
ann_data    = [climato_dir,'HYCOM_', ystr, '01.nc'];
insitu2pot       = 0;   %1: transform in-situ temperature to potential temperature

nc = netcdf(month_data);
temp_missing = max(max(max(nc{'temp'}(:))));
salt_missing = temp_missing; % You need to check the value
u_missing = temp_missing;
v_missing = temp_missing;
ssh_missing = temp_missing;

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
ext_tracers_ini_HYCOM_J(ininame,grdname,month_data,ann_data,temp_missing,...
    'temp','temp','r',tini);
disp(' ')
disp(' Salinity...')
ext_tracers_ini_HYCOM_J(ininame,grdname,month_data,ann_data,salt_missing,...
    'salt','salt','r',tini);
disp(' ')
disp(' U...')
ext_tracers_ini_HYCOM_J(ininame,grdname,month_data,ann_data,u_missing,...
    'u','u','u',tini);
disp(' ')
disp(' V...')
ext_tracers_ini_HYCOM_J(ininame,grdname,month_data,ann_data,v_missing,...
    'v','v','v',tini);

disp(' ')
disp(' SSH...')
nc = netcdf(month_data);
lat = nc{'latitude'}(:);
lon = nc{'longitude'}(:);
ssh = nc{'ssh'}(:);
close(nc)

ssh(isnan(ssh) == 1) = ssh_missing;
ro = 0; default = NaN;
data = get_missing_val(lon,lat,ssh,ssh_missing,ro,default);
ssh_ROMS = griddata(lat, lon, data, lat_rho, lon_rho);
inc = netcdf(ininame, 'w');
inc{'zeta'}(:) = ssh_ROMS;
close(inc)

disp(' ')
disp(' Ubar and Vbar...')
barotropic_currents_J(ininame,grdname,[1 0 0 0])

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
