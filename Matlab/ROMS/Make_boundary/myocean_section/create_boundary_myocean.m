clear; clc; close all

ROMS_title  = 'NorthPacific Model';
ROMS_config = 'NorthPacific';

OGCM_path = 'D:\Data\Ocean\Model\myocean\';
OGCM_prefix = 'myocean_';

bry_prefix='.\myocean_';
bry_suffix = '.nc';

rmdepth     = 0;         % Number of bottom levels to remove
%(This is usefull when there is no valid data at this level
%i.e if the depth in the domain is shallower than
%the OGCM depth)

% %Overlap parameters : before (_a) and after (_p) the months.
itolap_a=0;           %Overlap parameters

% Objective analysis decorrelation scale [m]
% (if Roa=0: simple extrapolation method; crude but much less costly)
%
%Roa=300e3;
Roa=0;

interp_method = 'linear';           % Interpolation method: 'linear' or 'cubic'

obc = [1 1 1 1]; % open boundaries (1 = open , [S E N W])

Ymin = 2018;
Ymax = 2018;
Mmin = 1;
Mmax = 12;

bndy_times = [15:30:365];

makeplot = 1;
%
% Get the model grid
%
g = grd('NWP');
grdname = g.grd_file;
theta_s = g.theta_s;
theta_b = g.theta_b;
hc      = g.hc;
N       = g.N;

nc = netcdf(grdname);
lon = nc{'lon_rho'}(:);
lat = nc{'lat_rho'}(:);
angle = nc{'angle'}(:);
h = nc{'h'}(:);
close(nc)

lonmin = min(min(lon));
lonmax = max(max(lon));
latmin = min(min(lat));
latmax = max(max(lat));
%
%------------------------------------------------------------------------------------
%
% Get the OGCM grid
grid_name = [OGCM_path, OGCM_prefix, 'east_monthly_', num2str(Ymin), num2char(Mmin,2), '.nc'];
nc = netcdf(grid_name);
Z = -nc{'depth'}(:);
NZ = length(Z);
NZ = NZ - rmdepth;
Z = Z(1:NZ);
close(nc)
%
% Loop on the years and the months
%
for Y = Ymin:Ymax
    if Y == Ymin
        mo_min = Mmin;
    else
        mo_min = 1;
    end
    if Y == Ymax
        mo_max = Mmax;
    else
        mo_max = 12;
    end
    
    for M = mo_min:mo_max
        disp(' ')
        disp(['Processing  year ',num2str(Y),...
            ' - month ',num2str(M)])
        disp(' ')
        
        %
        % Add 2 times step in the ROMS files: 1 at the beginning and 1 at the end
        %
        %nc = netcdf([OGCM_path, OGCM_prefix, num2str(Y), num2char(Mmin,2), '.nc']);
        OGCM_time = bndy_times(M);
        ntimes = length(OGCM_time);
        
        roms_time = 0*(1:ntimes+0);
        %
        % Create and open the ROMS files
        %
        bryname = [bry_prefix, 'Y', num2str(Y), ...
            'M', num2str(M), bry_suffix];
        
        create_bryfile_J(bryname, grdname, ROMS_title, [1 1 1 1],...
            theta_s, theta_b, hc, N,...
            roms_time, 0, 'clobber');
        nc_bry = netcdf(bryname, 'write');
        
        nc_clm = [];
        
        %
        % Perform the interpolations for the current month
        %
        disp(' Current month :')
        disp('================')
        for tndx_OGCM = 1:ntimes
            disp([' Time step : ',num2str(tndx_OGCM),' of ',num2str(ntimes),' :'])
            interp_OGCM_myocean(OGCM_path, OGCM_prefix, Y, M, Roa, interp_method, ...
                Z, M, nc_clm, nc_bry, g, angle, h, tndx_OGCM + itolap_a, obc)
        end
        %
        % Close the ROMS files
        %
        if ~isempty(nc_clm)
            close(nc_clm);
        end
        if ~isempty(nc_bry)
            close(nc_bry);
        end
        %
    end
end

%
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%

%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot == 1
    disp(' ')
    disp(' Make a few plots...')
    bryname=[bry_prefix, 'Y', num2str(Y), 'M', num2str(M), bry_suffix];
    figure
    test_bry(bryname,grdname,'temp',1,obc)
    figure
    test_bry(bryname,grdname,'salt',1,obc)
    figure
    test_bry(bryname,grdname,'u',1,obc)
    figure
    test_bry(bryname,grdname,'v',1,obc)
end