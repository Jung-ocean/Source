clear; clc

filename = 'ARDEMv2.0.nc';
filename_out = 'ARDEMv2.0_Bering_part.tif';

lon = ncread(filename, 'lon')-360;
lat = ncread(filename, 'lat');
z = ncread(filename, 'z')';

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);

% lon_target = [min(min(g.lon_rho)), max(max(g.lon_rho))];
% lat_target = [min(min(g.lat_rho)), max(max(g.lat_rho))];

lon_target = [162 163]-360;
lat_target = [58 59];

lonind = find(lon > lon_target(1)-0.01 & lon < lon_target(2)+0.02);
latind = find(lat > lat_target(1)-0.02 & lat < lat_target(2)+0.02);

lon_new = lon(lonind)+360;
lat_new = lat(latind);
z_new = z(latind,lonind);

lon = lon_new;
lat = lat_new;
surface = z_new;

R = georasterref('RasterSize',size(surface),'LatitudeLimits',[min(lat),max(lat)],'LongitudeLimits',[min(lon),max(lon)]);
tiffile = filename_out;
geotiffwrite(tiffile,surface,R)

figure
plot_map('Bering', 'mercator', 'l')
geoshow(tiffile, 'DisplayType','surface')