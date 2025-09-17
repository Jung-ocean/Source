%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot domain of several models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

FS = 20;

figure; 
plot_map('WCOFS', 'mercator', 'l');
set(gcf, 'Position', [1 200 500 800])

% OSU_ROMS
gn = grd('NANOOS');
lat = gn.lat_rho;
lon = gn.lon_rho;

plotm([min(lat(:)) min(lat(:)) max(lat(:)) max(lat(:)) min(lat(:))], ...
    [max(lon(:)) min(lon(:)) min(lon(:)) max(lon(:)) max(lon(:))], ...
    '--k', 'LineWidth',3)
textm(39, -134.5, ['OSU ROMS'], 'Color', 'k', 'FontSize', FS)

% WCOFS
gw = grd('WCOFS');
lat = gw.lat_rho;
lon = gw.lon_rho;
tl = find(lon(:) == min(lon(:)));
tr = find(lat(:) == max(lat(:)));
bl = find(lat(:) == min(lat(:)));
br = find(lon(:) == max(lon(:)));

bndy_plot = gw.mask_rho.*0 + 1;
k = boundary(lon(:), lat(:), 1);
plotm(lat(k), lon(k), '--r', 'LineWidth', 3)
textm(30, -141, ['WCOFS'], 'Color', 'r', 'FontSize', FS)

% LiveOcean
plotm([42 42 52 52 42], [-122 -130 -130 -122 -122], '--b', 'LineWidth', 3)
textm(53, -137, ['LiveOcean'], 'Color', 'b', 'FontSize', FS)

print('domain_models', '-dpng')