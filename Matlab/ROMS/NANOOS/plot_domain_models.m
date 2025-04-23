%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot domain of several models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

g = grd('NANOOS');
lat = g.lat_rho;
lon = g.lon_rho;
startdate = datenum(2005,1,1);

FS = 15;

figure; 
plot_map('WCOFS', 'mercator', 'l');
set(gcf, 'Position', [1 200 500 650])

% OSU_ROMS
plotm([min(lat(:)) min(lat(:)) max(lat(:)) max(lat(:)) min(lat(:))], ...
    [max(lon(:)) min(lon(:)) min(lon(:)) max(lon(:)) max(lon(:))], ...
    '-k', 'LineWidth', 2)
textm(39, -129, ['NANOOS'], 'Color', 'k', 'FontSize', FS)

% WCOFS
file = '/data/sdurski/COAWST_NASA/WCOFS-A/grd_wcofs_large_visc200.nc';
lat = ncread(file, 'lat_rho');
lon = ncread(file, 'lon_rho');
tl = find(lon(:) == min(lon(:)));
tr = find(lat(:) == max(lat(:)));
bl = find(lat(:) == min(lat(:)));
br = find(lon(:) == max(lon(:)));

plotm([lat(tl) lat(tr) lat(br) lat(bl) lat(tl)], ...
    [lon(tl) lon(tr) lon(br) lon(bl) lon(tl)], '--b', 'LineWidth', 2)
textm(30, -138, ['WCOFS'], 'Color', 'b', 'FontSize', FS)
% LiveOcean
plotm([42 42 52 52 42], [-122 -130 -130 -122 -122], '--r', 'LineWidth', 2)
textm(53, -135, ['LiveOcean'], 'Color', 'r', 'FontSize', FS)

print('domain_models', '-dpng')