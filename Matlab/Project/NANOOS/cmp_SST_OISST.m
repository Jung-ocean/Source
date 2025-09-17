%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'temp';
map = 'US_west';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 12;
mstr = num2str(mm, '%02i');

switch vari_str
    case 'temp'
        load rmse_SST_OISST.mat % for mask

        title_str = ['SST (', datestr(datenum(yyyy,mm,15), 'mmm yyyy'), ')'];

        filepath_obs = '/data/jungjih/Observations/Satellite_SST/OISST/monthly/';
        filename_obs = ['OISST_monthly_', ystr, mstr, '.nc'];
        file_obs = [filepath_obs, filename_obs];
        lat_obs = double(ncread(file_obs, 'lat'));
        lon_obs = double(ncread(file_obs, 'lon'));
        lon_obs = lon_obs-360;

        [lon_limit, lat_limit] = load_domain(map);
        lonind = find(lon_obs > min(lon_limit) & lon_obs < max(lon_limit));
        latind = find(lat_obs > min(lat_limit) & lat_obs < max(lat_limit));
        
        [lat_obs2, lon_obs2] = meshgrid(lat_obs(latind), lon_obs(lonind));
        vari_obs_tmp = ncread(file_obs, 'sst');
        vari_obs = vari_obs_tmp(lonind, latind);
        
        nanind = setdiff(1:size(lat_obs2,1)*size(lat_obs2,2), index_common);
        vari_obs(nanind) = NaN;

        title_obs = 'OISST 2.1';

        cm = 'jet';
        climit = [6 24];
        interval = 1;
        [color, contour_interval] = get_color(cm, climit, interval);

        cm2 = 'redblue';
        climit2 = [-2 2];
        interval2 = .2;
        [color2, contour_interval2] = get_color(cm2, climit2, interval2);

        unit = '^oC';
end

FS = 12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
t = tiledlayout(1,3);
title(t, {title_str, ''}, 'FontSize', 15);

% Observation
ax1 = nexttile(1); hold on; grid on;
plot_map(map, 'mercator', 'l');
g = grd('NANOOS');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

pobs = plot_contourf(ax1, lat_obs2, lon_obs2, vari_obs, color, climit, contour_interval);
uistack(pobs, 'bottom')

c = colorbar;
c.Title.String = unit;
c.FontSize = FS;

title(title_obs, 'FontSize', FS);

% plotm(lat_obs2(index_common), lon_obs2(index_common),'.r')

% NANOOS diff
vari_NANOOS = load_models_surf_monthly('NANOOS', vari_str, yyyy, mm);
FN = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), vari_NANOOS(:));
vari_NANOOS_interp = FN(lat_obs2, lon_obs2);
vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;
vari_NANOOS_diff(nanind) = NaN;

ax2 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

pNd = plot_contourf(ax2, lat_obs2, lon_obs2, vari_NANOOS_diff, color2, climit2, contour_interval2);
uistack(pNd, 'bottom')

title(['Diff (NANOOS - obs)'], 'FontSize', FS);

plabel('off')

% WCOFS diff
gw = grd('WCOFS');
vari_WCOFS = load_models_surf_monthly('WCOFS', vari_str, yyyy, mm);
FW = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), vari_WCOFS(:));
vari_WCOFS_interp = FW(lat_obs2, lon_obs2);
vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;
vari_WCOFS_diff(nanind) = NaN;

ax3 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

pWd = plot_contourf(ax3, lat_obs2, lon_obs2, vari_WCOFS_diff, color2, climit2, contour_interval2);
uistack(pWd, 'bottom')

title(['Diff (WCOFS - obs)'], 'FontSize', FS);

plabel('off')

c2 = colorbar;
c2.Title.String = unit;
c2.FontSize = FS;
c2.Ticks = contour_interval2(1:2:end);

t.Padding = 'compact';
t.TileSpacing = 'compact';

print(['cmp_SST_OISST_', ystr, mstr], '-dpng')