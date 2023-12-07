%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a ROMS initial file from Levitus Data
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get initial conditions for
%  ROMS (initial netcdf files) .
%  Get the velocities and sea surface elevation via a 
%  geostrophic computation.
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
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

casename = 'EYECS_20190903_2';
year = 2012; ystr = num2str(year);

%
%  Title 
%
title='Climatology';
%
% Common parameters
%
climato_dir = 'D:\Data\Ocean\WOA\';
ininame = ['roms_ini_', casename, '_WOA_',  ystr,'.nc'];
g = grd(casename);
grdname = g.grd_file;
theta_s = g.theta_s;
theta_b = g.theta_b;
hc = g.hc;
N = g.N;
tini = 0;

vtransform = 2;

coastfileplot = 'm_coasts.mat';
%
%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
temp_month_data  = [climato_dir,'eas_decav_t01_10.nc'];
temp_ann_data    = [climato_dir,'eas_decav_t01_10.nc'];
insitu2pot       = 1;   %1: transform in-situ temperature to potential temperature
salt_month_data  = [climato_dir,'eas_decav_s01_10.nc'];
salt_ann_data    = [climato_dir,'eas_decav_s01_10.nc'];
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
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
create_inifile_J(ininame,grdname,title,...
               theta_s,theta_b,hc,N,...
               tini,'clobber',vtransform);
%
% Horizontal and vertical interp/extrapolations 
%
disp(' ')
disp(' Interpolations / extrapolations')
disp(' ')
disp(' Temperature...')
ext_tracers_ini_J(ininame,grdname,temp_month_data,temp_ann_data,...
            't_an','temp','r',tini);
disp(' ')
disp(' Salinity...')
ext_tracers_ini_J(ininame,grdname,salt_month_data,salt_ann_data,...
             's_an','salt','r',tini);
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
test_clim(ininame,grdname,'temp',1, coastfileplot)
figure
test_clim(ininame,grdname,'salt',1, coastfileplot)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
