clear; clc; close all

file_river = 'BS_6rivers_others_2017_2022.nc';

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);

figure; hold on
pcolor(g.lon_rho, g.lat_rho, g.mask_rho./g.mask_rho); shading interp

[han,lon,lat] = roms_plot_river_source_locations(file_river,g,'r');

dis = ncread(file_river, 'river_transport');
min_dis = min(dis, [], 2);
max_dis = max(dis, [], 2);

for r = 1:length(lon)
    text(lon(r),lat(r)-0.05,[num2str(min_dis(r), '%.2e'), ' ', num2str(max_dis(r), '%.2e')],'fontsize',10)
end