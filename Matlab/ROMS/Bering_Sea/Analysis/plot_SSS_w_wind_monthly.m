%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSS with wind
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4_mk2';
region = 'NW_Bering';

% Load grid information
g = grd('BSf');

vari_str = 'salt';
yyyy = 2023;
ystr = num2str(yyyy);
mm = 8;
mstr = num2str(mm, '%02i');
title_mstr = datestr(datenum(yyyy,mm,15),'mmm');

colormap = 'jet';
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'psu';

climit2 = [-2 2];
interval2 = 0.5;
[color2, contour_interval2] = get_color('redblue', climit2, interval2);

figure;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';

% Multi-year mean
nexttile(1); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

vari_climate = load_models_2d_monthly(exp, vari_str, g.N, 9999, mm);
plot_contourf([], g.lat_rho, g.lon_rho, vari_climate, color, climit, contour_interval);
plot_wind_ERA5(region, 9999, mm, 'k', 1);

title(['SSS in ', title_mstr, ' (Multi-year mean)'], 'FontSize', 15)

% Each year
nexttile(2); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

vari = load_models_2d_monthly(exp, vari_str, g.N, yyyy, mm);
plot_contourf([], g.lat_rho, g.lon_rho, vari, color, climit, contour_interval);
plot_wind_ERA5(region, yyyy, mm, 'k', 1);

c = colorbar;
c.Title.String = unit;
c.FontSize = 15;

plabel('off')

title(['SSS in ', title_mstr, ' ', ystr], 'FontSize', 15)

% Difference
ax3 = nexttile(3); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

plot_contourf(ax3, g.lat_rho, g.lon_rho, vari-vari_climate, color2, climit2, contour_interval2);
   
c = colorbar;
c.Title.String = unit;
c.FontSize = 15;

plabel('off')

title('Difference', 'FontSize', 15)

print(['SSS_w_wind_', ystr, mstr],'-dpng');