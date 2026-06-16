%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot domain of Oregon models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

FS = 20;

figure; 
plot_map('US_west_NANOOS', 'mercator', 'l');
set(gcf, 'Position', [1 200 500 800])

% LiveOcean
plotm([42 42 52 52 42], [-122 -130 -130 -122 -122], '-b', 'LineWidth', 3)
textm(52.5, -127, ['LiveOcean'], 'Color', 'b', 'FontSize', FS)

% OR
file = '/data/jungjih/Project/NOAA_NOPP_Carbon/Grid/grid_Oregon_1km_3.nc';
lon_rho = ncread(file, 'lon_rho');
lat_rho = ncread(file, 'lat_rho');
mask_rho = ncread(file, 'mask_rho');
h = ncread(file, 'h');

min_lon = min(lon_rho(:));
max_lon = max(lon_rho(:));
min_lat = min(lat_rho(:));
max_lat = max(lat_rho(:));

pcolorm(lat_rho, lon_rho, h.*mask_rho./mask_rho);
caxis([0 4000])

colors = load('/home/server/pi/homes/jungjih/Source/Matlab/Tools/ncview/ncview_colormaps.mat');
color = colors.cm_hotres;
colormap(color)
c = colorbar;
c.Title.String = 'm';

plotm([min_lat min_lat max_lat max_lat min_lat], [max_lon min_lon min_lon max_lon max_lon], '--k', 'LineWidth', 3)
textm(48.5, -128, ['Oregon'], 'Color', 'k', 'FontSize', FS)

print('domain_Oregon_1km', '-dpng')