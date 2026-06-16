clear; clc; close all

vari_str = 'mean';
isseason = 0;
season = 'winter';

g = grd('BSf');

region = 'Bering';
[lon_lim, lat_lim] = load_domain(region);

% Figure properties
switch vari_str
    case 'mean'
        climit = [32.7 33.2];
        interval = 0.05;
    case 'std'
        climit = [0 .5];
        interval = 0.025;
end
[color, contour_interval] = get_color('redblue', climit, interval);
unit = 'psu';
FS = 15;

f1 = figure; hold on;
set(f1, 'Position', [1 200 1700 800])
t1 = tiledlayout(2,3);
t1.Padding = 'compact';
t1.TileSpacing = 'tight';
if isseason == 1
    if strcmp(season, 'winter')
        title(t1, {['SSS ', season, ' JFM ', vari_str, ' (2019-2023 except for BEC SMOS 2018-2022)']}, 'FontSize', 20)
    elseif strcmp(season, 'summer')
        title(t1, {['SSS ', season, ' JAS ', vari_str, ' (2019-2023 except for BEC SMOS 2018-2022)']}, 'FontSize', 20)
    end
else
    title(t1, {['SSS ', vari_str, ' (2019-2023 except for BEC SMOS 2018-2022)']}, 'FontSize', 20)
end

% ARGO BOA
num_tile = 1;
if isseason == 1
    filepath = ['/data/jungjih/Observations/ARGO_BOA/mean_std_2019_2023_', season, '/'];
else
    filepath = '/data/jungjih/Observations/ARGO_BOA/mean_std_2019_2023/';
end
file_mean = [filepath, 'mean.mat'];
file_std = [filepath, 'std.mat'];

SSS_mean = load(file_mean);
lon = SSS_mean.lon-360;
lat = SSS_mean.lat;
SSS_mean = SSS_mean.SSS_mean;
SSS_std = load(file_std);
SSS_std = SSS_std.SSS_std;

lonind = find(lon(:,1) > min(lon_lim)-1 & lon(:,1) < max(lon_lim)+1);
latind = find(lat(1,:) > min(lat_lim)-1 & lat(1,:) < max(lat_lim)+1);

lon2 = lon(lonind, latind);
lat2 = lat(lonind, latind);
SSS_mean = SSS_mean(lonind, latind);
SSS_std = SSS_std(lonind, latind);
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(t1, num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('Argo BOA', 'FontSize', FS);
mlabel('off')
plabel('FontSize', 12)

% OISSS v2.0
num_tile = 2;
if isseason == 1
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('OISSS', 2, season);
else
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('OISSS', 2);
end

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_mean = SSS_mean(lonind, latind);
SSS_std = SSS_std(lonind, latind);
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(t1, num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('OISSS v2', 'FontSize', FS);
plabel('off')
mlabel('off')

% ROMS
num_tile = 3;
if isseason == 1
    filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/mean_std_2019_2023_', season, '/'];
else
    filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/Dsm4_mk2/mean_std_2019_2023/';
end
file_mean = [filepath, 'mean.nc'];
file_std = [filepath, 'std.nc'];

lat = g.lat_rho;
lon = g.lon_rho;
SSS_mean = ncread(file_mean, 'salt');
SSS_std = ncread(file_std, 'salt');
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat, lon, vari, color, climit, contour_interval);
title('ROMS', 'FontSize', FS);
plabel('off')
mlabel('off')

% RSS SMAP v6.0
num_tile = 4;
if isseason == 1
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMAP', 6, season);
else
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMAP', 6);
end

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_mean = SSS_mean(lonind, latind);
SSS_std = SSS_std(lonind, latind);
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('RSS SMAP v6.0', 'FontSize', FS);
plabel('FontSize', 12)
mlabel('FontSize', 12)

% CEC SMOS v10
num_tile = 5;
if isseason == 1
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMOS', 10, season);
else
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMOS', 10);
end

lonind = find(lon > min(lon_lim)-1 & lon < max(lon_lim)+1);
latind = find(lat > min(lat_lim)-1 & lat < max(lat_lim)+1);
[lat2, lon2] = meshgrid(lat(latind), lon(lonind));
SSS_mean = SSS_mean(lonind, latind);
SSS_std = SSS_std(lonind, latind);
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('CEC SMOS v10', 'FontSize', FS);
plabel('off')
mlabel('FontSize', 12)

% BEC SMOS Arctic v4 (2018-2022)
num_tile = 6;
if isseason == 1
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMOS_BEC', 4, season);
else
    [lat, lon, SSS_mean, SSS_std] = load_SSS_sat_mean_std('SMOS_BEC', 4);
end

F = scatteredInterpolant(lat(:), lon(:), 0.*lat(:));
lat_sat_regular = [min(lat_lim)-1:0.25:max(lat_lim)+1]';
lon_sat_regular = [min(lon_lim)-1:0.25:max(lon_lim)+1]';
[lat2, lon2] = meshgrid(lat_sat_regular, lon_sat_regular);
F.Values = SSS_mean(:);
SSS_mean = F(lat2, lon2);
F.Values = SSS_std(:);
SSS_std = F(lat2, lon2);
vari = eval(['SSS_', vari_str]);

figure(f1); nexttile(num_tile); hold on;
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');
plot_contourf([], lat2, lon2, vari, color, climit, contour_interval);
title('BEC SMOS Arctic v4', 'FontSize', FS);
plabel('off')
mlabel('FontSize', 12)

c = colorbar;
c.Layout.Tile = 'East';
c.Title.String = unit;
c.FontSize = 12;

if isseason == 1
    print(['SSS_', vari_str, '_', season], '-dpng')
else
    print(['SSS_', vari_str], '-dpng')
end