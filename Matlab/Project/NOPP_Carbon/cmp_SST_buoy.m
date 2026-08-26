%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between buoy and model results
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

expname = 'WCOFS_nudg';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_', expname])

vari_str = 'temp';
map = 'Oregon';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 7;
mstr = num2str(mm, '%02i');

switch vari_str
    case 'temp'
        title_str = ['SST (', datestr(datenum(yyyy,mm,15), 'mmm yyyy'), ')'];

        filepath_obs = '/data/jungjih/Project/NANOOS/Intercomparison/';
        filename_obs = ['SST_buoy_monthly.mat'];
        file_obs = [filepath_obs, filename_obs];
        data = load(file_obs);
        
        timenum_obs = data.timenum;
        timevec_obs = datevec(timenum_obs);
        lat_obs = data.lats;
        lon_obs = data.lons;
        vari_obs_tmp = data.SST_monthly;
        index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm);
        vari_obs = vari_obs_tmp(:,index);

        nanind = isnan(vari_obs) == 1;
        lat_obs(nanind) = [];
        lon_obs(nanind) = [];
        vari_obs(nanind) = [];

        title_obs = 'Buoy';

        cm = 'jet';
        climit = [6 20];
        interval = 1;
        [color, contour_interval] = get_color(cm, climit, interval);

        cm2 = 'redblue';
        climit2 = [-3 3];
        interval2 = .25;
        [color2, contour_interval2] = get_color(cm2, climit2, interval2);

        unit = '^oC';
end

FS = 12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 600])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';
title(t, {title_str}, 'FontSize', 20);

% Observation
ax1 = nexttile(1); hold on; grid on;
plot_map(map, 'mercator', 'l');
g = grd('Oregon_1km');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

pobs = scatterm(ax1, lat_obs, lon_obs, 60, vari_obs, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax1, color)
caxis(ax1, climit)

title(title_obs, 'FontSize', FS);

% plotm(lat_obs2(index_common), lon_obs2(index_common),'.r')

% ROMS
vari_NANOOS = load_models_surf_monthly('Oregon_1km', expname, vari_str, yyyy, mm);
Fn = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), vari_NANOOS(:));
vari_ROMS_interp = Fn(lat_obs, lon_obs);

ax2 = nexttile(2); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

pNd = scatterm(ax2, lat_obs, lon_obs, 60, vari_ROMS_interp, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax2, color)
caxis(ax2, climit)
c = colorbar;
c.Title.String = unit;
c.FontSize = FS;
title(['ROMS'], 'FontSize', FS);

plabel('off')

% Difference
vari_ROMS_diff = vari_ROMS_interp - vari_obs;

ax3 = nexttile(3); hold on; grid on;
plot_map(map, 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

pNd = scatterm(ax3, lat_obs, lon_obs, 60, vari_ROMS_diff, 'Filled', 'MarkerEdgeColor', 'k');
colormap(ax3, color2)
caxis(ax3, climit2)
c2 = colorbar;
c2.Title.String = unit;
c2.FontSize = FS;
c2.Ticks = contour_interval2(1:2:end);

title(['Diff (ROMS - obs)'], 'FontSize', FS);

plabel('off')

print(['cmp_SST_buoy_', ystr, mstr], '-dpng')