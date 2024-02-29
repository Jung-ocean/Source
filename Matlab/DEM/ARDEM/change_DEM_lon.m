clear; clc;

filename = 'ARDEMv2.0.nc';
filename_out = 'ARDEMv2.0_Bering.nc';

lon = ncread(filename, 'lon')-360;
lat = ncread(filename, 'lat');
z = ncread(filename, 'z')';

% figure;
% pcolor(lon, lat, z); shading interp

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);

lon_target = [min(min(g.lon_rho)), max(max(g.lon_rho))];
lat_target = [min(min(g.lat_rho)), max(max(g.lat_rho))];

xlim(lon_target);
ylim(lat_target);

lonind = find(lon > lon_target(1)-0.01 & lon < lon_target(2)+0.02);
latind = find(lat > lat_target(1)-0.02 & lat < lat_target(2)+0.02);

lon_new = lon(lonind);
lat_new = lat(latind);
z_new = z(latind,lonind);

ROMS = [lon_target; lat_target]
ARDEM_new = [min(lon_new), max(lon_new); min(lat_new), max(lat_new)]

lon_new = lon_new + 360;
index1 = find(lon_new > 180);
index2 = find(lon_new <= 180);
lon_new(index1) = lon_new(index1) - 360;

figure; hold on;
plot_map('Bering', 'mercator', 'l')
pcolorm(lat_new, lon_new, z_new); shading interp

mySchema = ncinfo('ARDEMv2.0.nc');
mySchema.Dimensions(1).Length = length(lon_new);
mySchema.Dimensions(2).Length = length(lat_new);
mySchema.Variables = [];
ncwriteschema(filename_out, mySchema);

nccreate(filename_out, 'lon', 'Dimension', {'lon'})
nccreate(filename_out, 'lat', 'Dimension', {'lat'})
nccreate(filename_out, 'z', 'Dimension', {'lon', 'lat'})

ncwrite(filename_out, 'lon', lon_new)
ncwrite(filename_out, 'lat', lat_new)
ncwrite(filename_out, 'z', z_new')
