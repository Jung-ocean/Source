%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate sea ice concentration using ASI data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2015:2023;
mm_all = 5:5;

filepath_monthly = '/data/jungjih/Observations/Sea_ice/ASI/monthly_ROMSgrid/';

grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);
lat = g.lat_rho;
lon = g.lon_rho;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

region = 'eoshelf';
mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
indmask = eval(['mask_Scott.ind', region]);
[row,col] = ind2sub([1460, 957], indmask);
indmask = sub2ind([957, 1460], col, row); % transpose

Fi = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        file = [filepath_monthly, 'asi-AMSR2-n6250-', ystr, mstr, '-v5.4.nc'];

        lon = ncread(file, 'longitude')';
        lat = ncread(file, 'latitude')';
        sic = ncread(file, 'z')';
        
        Fi(yi) = sum(sic(indmask).*area(indmask), 'omitnan')./sum(area(indmask), 'omitnan');
    end
end

figure; hold on; grid on;
plot(yyyy_all, Fi, '-o')

save(['Fi_ASI_', mstr, '_', region, '.mat'], 'Fi')