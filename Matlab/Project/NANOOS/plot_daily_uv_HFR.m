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
mm = 7;
dd = 12;

gn = grd('NANOOS');
Fn = scatteredInterpolant(gn.lat_rho(:), gn.lon_rho(:), 0.*gn.lat_rho(:));
Fn.ExtrapolationMethod = 'none';

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));
Fw.ExtrapolationMethod = 'none';

vari_str = 'uv';
map = 'Heceta';

load(['metrics_', vari_str, '_HFR_', ystr, '.mat'])

FS = 15;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1100 900])
t = tiledlayout(2,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

timenum = datenum(yyyy,mm,dd);
yyyymmdd = datestr(timenum, 'yyyymmdd');
title(t, yyyymmdd, 'FontSize', 25)

% Observation
[lon_obs, lat_obs, u_obs_tmp, v_obs_tmp] = load_HFR_daily(timenum);
lonind = find(lon_obs > min(gn.lon_rho(:)) & lon_obs < max(gn.lon_rho(:)));
latind = find(lat_obs > min(gn.lat_rho(:)) & lat_obs < max(gn.lat_rho(:)));
[lat2, lon2] = meshgrid(lat_obs(latind), lon_obs(lonind));
u_obs = u_obs_tmp(lonind, latind);
v_obs = v_obs_tmp(lonind, latind);

ax1 = nexttile(1); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
cl = clabelm(cs, h);
set(cl, 'BackgroundColor', 'none');

interval = 1;
q = plot_vectors(map, lon2, lat2, u_obs.*mask, v_obs.*mask, interval, 'k', 1);

title('Observation', 'FontSize', FS);

% NANOOS
u_NANOOS = 100.*load_models_surf_daily('NANOOS', 'u', yyyy, mm, dd);
Fn.Values = u_NANOOS(:);
u_NANOOS_interp = Fn(lat2, lon2);
v_NANOOS = 100.*load_models_surf_daily('NANOOS', 'v', yyyy, mm, dd);
Fn.Values = v_NANOOS(:);
v_NANOOS_interp = Fn(lat2, lon2);

ax2 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, u_NANOOS_interp.*mask, v_NANOOS_interp.*mask, interval, 'k', 0);

title('OSU ROMS', 'FontSize', FS);

plabel('off')
mlabel('off')

% NANOOS - Observation
ax3 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, (u_NANOOS_interp - u_obs_mean).*mask, (v_NANOOS_interp - v_obs_mean).*mask, interval, 'k', 0);

title('Diff (OSU ROMS - Obs)', 'FontSize', FS);

plabel('off')
mlabel('off')

% WCOFS
u_WCOFS = 100.*load_models_surf_daily('WCOFS', 'u', yyyy, mm, dd);
Fw.Values = u_WCOFS(:);
u_WCOFS_interp = Fw(lat2, lon2);
v_WCOFS = 100.*load_models_surf_daily('WCOFS', 'v', yyyy, mm, dd);
Fw.Values = v_WCOFS(:);
v_WCOFS_interp = Fw(lat2, lon2);

ax5 = nexttile(5); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gw.lat_rho, gw.lon_rho, gw.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, u_WCOFS_interp.*mask, v_WCOFS_interp.*mask, interval, 'k', 0);

title('WCOFS', 'FontSize', FS);

% WCOFS - Observation
ax6 = nexttile(6); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gw.lat_rho, gw.lon_rho, gw.h, [50 100 200], 'k');
interval = 1;
q = plot_vectors(map, lon2, lat2, (u_WCOFS_interp - u_obs_mean).*mask, (v_WCOFS_interp - v_obs_mean).*mask, interval, 'k', 0);

title('Diff (WCOFS - Obs)', 'FontSize', FS);

plabel('off')

print(['daily_', vari_str, '_HFR_', map, '_', yyyymmdd], '-dpng')