%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

gn = grd('NANOOS');
gw = grd('WCOFS');

vari_str = 'temp';
map = 'US_west';

load metrics_SST_OISST_point.mat

% nanind = setdiff(1:size(lat_obs2,1)*size(lat_obs2,2), index_common);
% vari_obs(nanind) = NaN;

FS = 12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 900 900])
t = tiledlayout(2,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';

% Bias
colormap = 'redblue';
climit = [-1 1];
interval = .1;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = '^oC';

% NANOOS
ax1 = nexttile(1); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasn = plot_contourf(ax1, lat_obs2, lon_obs2, bias_NANOOS, color, climit, contour_interval);
uistack(pbiasn, 'bottom')

title('OSU ROMS bias', 'FontSize', FS);

% WCOFS
ax1 = nexttile(4); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasw = plot_contourf(ax1, lat_obs2, lon_obs2, bias_WCOFS, color, climit, contour_interval);
uistack(pbiasw, 'bottom')

title('WCOFS bias', 'FontSize', FS);

mlabel off

c = colorbar;
c.Label.String = unit;
c.FontSize = FS;
c.Location = 'SouthOutside';

% rmse
colormap = 'jet';
climit = [0 1];
interval = .1;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = '^oC';

% NANOOS
ax1 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasn = plot_contourf(ax1, lat_obs2, lon_obs2, rmse_NANOOS, color, climit, contour_interval);
uistack(pbiasn, 'bottom')

title('OSU ROMS RMSE', 'FontSize', FS);

% WCOFS
ax1 = nexttile(5); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasw = plot_contourf(ax1, lat_obs2, lon_obs2, rmse_WCOFS, color, climit, contour_interval);
uistack(pbiasw, 'bottom')

title('WCOFS RMSE', 'FontSize', FS);

mlabel off

c = colorbar;
c.Label.String = unit;
c.FontSize = FS;
c.Location = 'SouthOutside';

% correlation coefficient
colormap = 'jet';
climit = [.6 1];
interval = .02;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = '';

% NANOOS
ax1 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasn = plot_contourf(ax1, lat_obs2, lon_obs2, corrcoef_NANOOS, color, climit, contour_interval);
uistack(pbiasn, 'bottom')

title('OSU ROMS corr coef', 'FontSize', FS);

% WCOFS
ax1 = nexttile(6); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');

pbiasw = plot_contourf(ax1, lat_obs2, lon_obs2, corrcoef_WCOFS, color, climit, contour_interval);
uistack(pbiasw, 'bottom')

title('WCOFS corr coef', 'FontSize', FS);

mlabel off

c = colorbar;
c.Label.String = unit;
c.FontSize = FS;
c.Location = 'SouthOutside';

print(['metrics_SST_OISST'], '-dpng')