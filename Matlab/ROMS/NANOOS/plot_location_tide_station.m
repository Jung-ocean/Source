%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot tide station locations
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'US_west';
g = grd('NANOOS');

load_NOAA_station_info

figure; hold on;
set(gcf, 'Position', [1 200 500 800])
plot_map(map, 'mercator', 'l')
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

for si = 1:length(stations)
    plotm(lats(si), lons(si), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
end

print('location_tide_station', '-dpng')