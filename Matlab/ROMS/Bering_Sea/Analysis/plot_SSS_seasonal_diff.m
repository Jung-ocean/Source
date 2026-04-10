clear; clc; close all

yyyy = 2019;
ystr = num2str(yyyy);
vari_str = 'seasonal_diff';

g = grd('BSf');

region = 'Bering';
[lon_lim, lat_lim] = load_domain(region);

% Figure properties
switch vari_str
    case 'seasonal_diff'
        climit = [-1 1];
        interval = 0.25;
end
[color, contour_interval] = get_color('redblue', climit, interval);
unit = 'psu';
FS = 15;

f1 = figure; hold on;
set(f1, 'Position', [1 200 1700 800])
t1 = tiledlayout(2,3);
t1.Padding = 'compact';
t1.TileSpacing = 'tight';
title(t1, {['SSS summer (JAS) - winter (JFM), ', ystr], ' '}, 'FontSize', 20)

% ARGO BOA
num_tile = 1;
filepath = '/data/jungjih/Observations/ARGO_BOA/seasonal/';
file_winter = [filepath, 'mean_', ystr, '_JFM.mat'];
file_summer = [filepath, 'mean_', ystr, '_JAS.mat'];

SSS_winter = load(file_winter);
lon = SSS_winter.lon-360;
lat = SSS_winter.lat;
SSS_winter = SSS_winter.SSS_mean;
SSS_summer = load(file_summer);
SSS_summer = SSS_summer.SSS_mean;
SSS_diff = SSS_summer - SSS_winter;

lonind = find(lon(:,1) > min(lon_lim)-1 & lon(:,1) < max(lon_lim)+1);
latind = find(lat(1,:) > min(lat_lim)-1 & lat(1,:) < max(lat_lim)+1);

lon2 = lon(lonind, latind);
lat2 = lat(lonind, latind);
SSS_diff = SSS_diff(lonind, latind);
vari = SSS_diff;

figure(f1); nexttile(t1, num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('Argo BOA', 'FontSize', FS);
mlabel('off')
plabel('FontSize', 12)

% OISSS v2.0
num_tile = 2;

[lat, lon, SSS_winter] = load_SSS_sat_seasonal('OISSS', 2, yyyy, 'JFM');
[lat, lon, SSS_summer] = load_SSS_sat_seasonal('OISSS', 2, yyyy, 'JAS');
SSS_diff = SSS_summer - SSS_winter;

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_diff = SSS_diff(lonind, latind);
vari = SSS_diff;

figure(f1); nexttile(t1, num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('OISSS v2', 'FontSize', FS);
plabel('off')
mlabel('off')

% ROMS
num_tile = 3;
filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/seasonal/'];
file_winter = [filepath, 'SSS_', ystr, '_JFM.nc'];
file_summer = [filepath, 'SSS_', ystr, '_JAS.nc'];

lat = g.lat_rho;
lon = g.lon_rho;
SSS_winter = ncread(file_winter, 'salt');
SSS_summer = ncread(file_summer, 'salt');
SSS_diff = SSS_summer - SSS_winter;
vari = SSS_diff;

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat, lon, vari, color, climit, contour_interval);
title('ROMS', 'FontSize', FS);
plabel('off')
mlabel('off')

% RSS SMAP v6.0
num_tile = 4;
[lat, lon, SSS_winter] = load_SSS_sat_seasonal('SMAP', 6, yyyy, 'JFM');
[lat, lon, SSS_summer] = load_SSS_sat_seasonal('SMAP', 6, yyyy, 'JAS');
SSS_diff = SSS_summer - SSS_winter;

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_diff = SSS_diff(lonind, latind);
vari = SSS_diff;

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('RSS SMAP v6.0', 'FontSize', FS);
plabel('FontSize', 12)
mlabel('FontSize', 12)

% CEC SMOS v10
num_tile = 5;
[lat, lon, SSS_winter] = load_SSS_sat_seasonal('SMOS', 10, yyyy, 'JFM');
[lat, lon, SSS_summer] = load_SSS_sat_seasonal('SMOS', 10, yyyy, 'JAS');
SSS_diff = SSS_summer - SSS_winter;

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_diff = SSS_diff(lonind, latind);
vari = SSS_diff;

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('CEC SMOS v10', 'FontSize', FS);
plabel('off')
mlabel('FontSize', 12)

% BEC SMOS Arctic v4 (2018-2022)
num_tile = 6;
[lat, lon, SSS_winter] = load_SSS_sat_seasonal('SMOS_BEC', 4, yyyy, 'JFM');
[lat, lon, SSS_summer] = load_SSS_sat_seasonal('SMOS_BEC', 4, yyyy, 'JAS');
SSS_diff = SSS_summer - SSS_winter;

F = scatteredInterpolant(lat(:), lon(:), 0.*lat(:));
lat_sat_regular = [min(lat_lim)-1:0.25:max(lat_lim)+1]';
lon_sat_regular = [min(lon_lim)-1:0.25:max(lon_lim)+1]';
[lat2, lon2] = meshgrid(lat_sat_regular, lon_sat_regular);
F.Values = SSS_diff(:);
SSS_diff = F(lat2, lon2);
vari = SSS_diff;

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('BEC SMOS v4', 'FontSize', FS);
plabel('off')
mlabel('FontSize', 12)

c = colorbar;
c.Layout.Tile = 'East';
c.Title.String = unit;
c.Ticks = contour_interval;
c.FontSize = 12;

print(['SSS_', vari_str, '_', ystr], '-dpng')