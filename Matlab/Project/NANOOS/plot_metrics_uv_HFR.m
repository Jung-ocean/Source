%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2024;
ystr = num2str(yyyy);

gn = grd('NANOOS');
gw = grd('WCOFS');

vari_str = 'uv';
map = 'Columbia_River';

load(['metrics_', vari_str, '_HFR_', ystr, '.mat'])
% [lat2, lon2] = meshgrid(lat_obs, lon_obs);

FS = 15;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 900])
t = tiledlayout(2,4);
t.Padding = 'compact';
t.TileSpacing = 'compact';
title(t, {[datestr(timenum(1), 'mm/dd'), ' - ', datestr(timenum(end), 'mm/dd, yyyy')], ''}, 'FontSize', 25)

% Observation
ax1 = nexttile(1); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
cl = clabelm(cs, h);
set(cl, 'BackgroundColor', 'none');

interval = 1;
q = plot_vectors('Oregon', lon2, lat2, u_obs_mean.*mask, v_obs_mean.*mask, interval, 'k', 1);

title('Observation', 'FontSize', FS);

% NANOOS
ax2 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, u_NANOOS_mean.*mask, v_NANOOS_mean.*mask, interval, 'k', 0);

title('OSU ROMS', 'FontSize', FS);

plabel('off')
mlabel('off')

% NANOOS - Observation
ax3 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, (u_NANOOS_mean - u_obs_mean).*mask, (v_NANOOS_mean - v_obs_mean).*mask, interval, 'k', 0);

title('Diff (OSU ROMS - Obs)', 'FontSize', FS);

plabel('off')
mlabel('off')

% NANOOS vrmse
ax4 = nexttile(4); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
index = find(isnan(vrmse_NANOOS.*mask) == 0);
q = scatterm(lat2(index), lon2(index), 60, vrmse_NANOOS(index), 's', 'filled', 'MarkerEdgeColor', 'k');
colormap(jet(30))
caxis([0 30])
c = colorbar;
c.Title.String = 'cm/s';
c.FontSize = FS;

title('RMSE', 'FontSize', FS);

plabel('off')
mlabel('off')

% WCOFS
ax6 = nexttile(6); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gw.lat_rho, gw.lon_rho, gw.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, u_WCOFS_mean.*mask, v_WCOFS_mean.*mask, interval, 'k', 0);

title('WCOFS', 'FontSize', FS);

% WCOFS - Observation
ax7 = nexttile(7); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gw.lat_rho, gw.lon_rho, gw.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, (u_WCOFS_mean - u_obs_mean).*mask, (v_WCOFS_mean - v_obs_mean).*mask, interval, 'k', 0);

title('Diff (WCOFS - Obs)', 'FontSize', FS);

plabel('off')

% WCOFS vrmse
ax8 = nexttile(8); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gw.lat_rho, gw.lon_rho, gw.h, [50 100 200], 'k');
index = find(isnan(vrmse_WCOFS.*mask) == 0);
q = scatterm(lat2(index), lon2(index), 60, vrmse_WCOFS(index), 's', 'filled', 'MarkerEdgeColor', 'k');
colormap(jet(30))
caxis([0 30])
c = colorbar;
c.Title.String = 'cm/s';
c.FontSize = FS;

title('RMSE', 'FontSize', FS);

plabel('off')

print(['metrics_', vari_str, '_HFR_', map, '_', ystr], '-dpng')