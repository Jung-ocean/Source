%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate sea ice extent area using the sea ice index geotiff file from NSIDC
%
% Geotiff file info
% sea ice concentration 0-1000 (divide by 10 to get percent)
% ocean 0
% pole hole 2510
% coast line 2530
% land 2540
% missing 2550
% Table 5 (https://nsidc.org/sites/default/files/g02135-v003-userguide_1_1.pdf)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2018:2018;
mm_all = 1:1;

filepath_monthly = '/data/jungjih/Observations/Sea_ice/NSIDC/geotiff/concentration/';

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

region = 'eoshelf';
mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
indmask = eval(['mask_Scott.ind', region]);
[row,col] = ind2sub([1460, 957], indmask);
indmask = sub2ind([957, 1460], col, row); % transpose

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        tiffile = [filepath_monthly, 'N_', ystr, mstr, '_concentration_v3.0.tif'];

        [Z,R] = readgeoraster(tiffile,"OutputType","double");
        Z(Z == 2530) = NaN;
        Z(Z == 2540) = NaN;
        [X,Y] = worldGrid(R);

        info = geotiffinfo(tiffile);
        [lat,lon] = projinv(info,X,Y);

        lon2 = g.lon_rho;
        lon2(lon2 < -180) = lon2(lon2 < -180) + 360;
        Z_interp = griddata(lon,lat,Z,lon2,g.lat_rho);

        figure; hold on; grid on
        plot_map('Bering', 'mercator', 'l')
        p = pcolorm(g.lat_rho, g.lon_rho, Z_interp/10);
       
        uistack(p, 'bottom')

    end
end