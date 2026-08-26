%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot domain of several models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

FS = 15;

g = grd('NANOOS');

figure; 
plot_map('US_west_shelf', 'mercator', 'l');
set(gcf, 'Position', [1 200 500 800])
[cs,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
cl = clabelm(cs,h, 'LabelSpacing', 300);
set(cl, 'BackgroundColor', 'none');

load metrics_uv_HFR_2024.mat
interval = 1;
q = plot_vectors('US_west_shelf', lon2, lat2, u_obs_mean.*mask, v_obs_mean.*mask, interval, 'k', 1);

% Columbia River
[lon, lat] = load_domain('Columbia_River');

plotm([min(lat) min(lat) max(lat) max(lat) min(lat)], ...
    [max(lon) min(lon) min(lon) max(lon) max(lon)], ...
    '-r', 'LineWidth',3)
% textm(max(lat)+.1, min(lon), ['Columbia River'], 'Color', 'r', 'FontSize', FS)

% Heceta Bank
[lon, lat] = load_domain('Heceta');

plotm([min(lat) min(lat) max(lat) max(lat) min(lat)], ...
    [max(lon) min(lon) min(lon) max(lon) max(lon)], ...
    '-r', 'LineWidth',3)
% textm(max(lat)+.1, min(lon), ['Heceta Bank'], 'Color', 'r', 'FontSize', FS)

% WA shelf, depth = 87 m
lon = -124.566;
lat = 46.9859;
plotm(lat, lon, '.b', 'MarkerSize', 30)
textm(lat+.15, lon-.7, ['Washington Shelf'], 'Color', 'b', 'FontSize', FS-3)

% OR shelf, depth = 80 m
lon = -124.304;
lat = 44.6393;
plotm(lat, lon, '.b', 'MarkerSize', 30)
textm(lat+.3, lon-.7, ['Oregon Shelf'], 'Color', 'b', 'FontSize', FS-3)

print('domain_HFR', '-dpng')