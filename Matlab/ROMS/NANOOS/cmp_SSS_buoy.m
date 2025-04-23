%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models to buoy
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
map = 'US_west';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 12;
mstr = num2str(mm, '%02i');

switch vari_str
    case 'salt'
        title_str = ['SSS (', datestr(datenum(yyyy,mm,15), 'mmm yyyy'), ')'];

        filepath_obs = '/data/jungjih/Project/NANOOS/';
        filename_obs = ['SSS_buoy_monthly.mat'];
        file_obs = [filepath_obs, filename_obs];
        data = load(file_obs);
        
        timenum_obs = data.timenum;
        timevec_obs = datevec(timenum_obs);
        lat_obs = data.lats;
        lon_obs = data.lons;
        vari_obs_tmp = data.SSS_monthly;
        index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm);
        vari_obs = vari_obs_tmp(:,index);

        title_obs = 'Buoy';

        cm = 'jet';
        climit = [29 34];
        interval = .25;
        [color, contour_interval] = get_color(cm, climit, interval);

        cm2 = 'redblue';
        climit2 = [-1 1];
        interval2 = .1;
        [color2, contour_interval2] = get_color(cm2, climit2, interval2);

        unit = 'psu';
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

pobs = scatterm(ax1, lat_obs, lon_obs, 60, vari_obs, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax1, color)
caxis(ax1, climit)
c = colorbar;
c.Title.String = unit;
c.FontSize = FS;

title(title_obs, 'FontSize', FS);

% plotm(lat_obs2(index_common), lon_obs2(index_common),'.r')

% NANOOS diff
vari_NANOOS = load_models_surf_monthly('NANOOS', vari_str, yyyy, mm);
Fn = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), vari_NANOOS(:));
vari_NANOOS_interp = Fn(lat_obs, lon_obs);
vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;

ax2 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

pNd = scatterm(ax2, lat_obs, lon_obs, 60, vari_NANOOS_diff, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax2, color2)
caxis(ax2, climit2)

title(['Diff (NANOOS - obs)'], 'FontSize', FS);

plabel('off')

% WCOFS diff
gw = grd('WCOFS');
vari_WCOFS = load_models_surf_monthly('WCOFS', vari_str, yyyy, mm);
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), vari_WCOFS(:));
vari_WCOFS_interp = Fw(lat_obs, lon_obs);
vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;

ax3 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

pWd = scatterm(ax3, lat_obs, lon_obs, 60, vari_WCOFS_diff, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax3, color2)
caxis(ax3, climit2)

title(['Diff (WCOFS - obs)'], 'FontSize', FS);

plabel('off')

c2 = colorbar;
c2.Title.String = unit;
c2.FontSize = FS;
c2.Ticks = contour_interval2(1:2:end);

t.Padding = 'compact';
t.TileSpacing = 'compact';

print(['cmp_SSS_buoy_', ystr, mstr], '-dpng')