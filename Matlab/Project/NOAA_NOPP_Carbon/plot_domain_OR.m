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
file = '/data/jungjih/Project/NOAA_NOPP_Carbon/Grid/Oregon_coast_grid3.nc';
lon_rho = ncread(file, 'lon_rho');
lat_rho = ncread(file, 'lat_rho');
mask_rho = ncread(file, 'mask_rho');
h = ncread(file, 'h');
pcolorm(lat_rho, lon_rho, h.*mask_rho./mask_rho);

colors = load('/home/server/pi/homes/jungjih/Source/Matlab/Tools/ncview/ncview_colormaps.mat');
color = colors.cm_hotres;
colormap(color)
c = colorbar;
c.Title.String = 'm';

plotm([42 42 47.98 47.98 42], [-123.3 -128 -128 -123.3 -123.3], '--k', 'LineWidth', 3)
textm(48.5, -128, ['Oregon'], 'Color', 'k', 'FontSize', FS)
ddd
print('domain_OR', '-dpng')