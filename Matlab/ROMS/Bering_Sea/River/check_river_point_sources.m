clear; clc; close all

file_river = 'BS_6rivers_others_2017_2025.nc';

% Load grid information
g = grd('BSf');
g.mask_rho = g.mask_rho';
g.lon_rho = g.lon_rho';
g.lat_rho = g.lat_rho';
g.lon_u = g.lon_u';
g.lat_u = g.lat_u';
g.lon_v = g.lon_v';
g.lat_v = g.lat_v';

figure; hold on
pcolor(g.lon_rho, g.lat_rho, g.mask_rho./g.mask_rho); shading interp

[han,lon,lat] = roms_plot_river_source_locations(file_river,g,'r');

dis = ncread(file_river, 'river_transport');
min_dis = min(dis, [], 2);
max_dis = max(dis, [], 2);

for r = 1:length(lon)
    text(lon(r),lat(r)-0.05,[num2str(min_dis(r), '%.2e'), ' ', num2str(max_dis(r), '%.2e')],'fontsize',10)
end