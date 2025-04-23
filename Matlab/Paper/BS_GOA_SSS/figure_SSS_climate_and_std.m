clear; clc; close all

map = 'Gulf_of_Anadyr';

mm = 7;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

% Satellite
lons_sat = {'lon', 'lon'};
lons_360ind = [360 180];
lats_sat = {'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS'};
titles_sat = {'RSS SMAP SSS', 'CEC SMOS SSS'};

% Figure properties
climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';
savename = 'SSS';

climit2 = [0 2];
interval2 = 0.25;
contour_interval2 = climit2(1):interval2:climit2(2);
num_color2 = diff(climit2)/interval2;
color2 = jet(num_color2);

f = figure;
set(gcf, 'Position', [1 200 1500 600])

% SMAP SSS
si = 1;
% RSS SMAP v6.0
filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/climate/'];

filepath_sat = filepath_RSS_70;
filepattern1_sat = fullfile(filepath_sat, (['*climate_', mstr, '*.nc']));

filename_sat = dir(filepattern1_sat);
if isempty(filename_sat)
    filename_sat = dir(filepattern2_sat);
end

file_sat = [filepath_sat, filename_sat.name];
lon_sat = double(ncread(file_sat,lons_sat{si}));
lat_sat = double(ncread(file_sat,lats_sat{si}));
vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

file_std = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/std/RSS_smap_SSS_L3_std_', mstr, '_FNL_v06.0.nc'];
std_sat = double(squeeze(ncread(file_std,varis_sat{si}))');

lon_sat = lon_sat - lons_360ind(si);

latind = find(40<lat_sat & lat_sat <80);
lonind = find(-250<lon_sat & lon_sat <-100);
lat_sat = lat_sat(latind);
lon_sat = lon_sat(lonind);
vari_sat = vari_sat(latind,lonind);
std_sat = std_sat(latind,lonind);
[lon2, lat2] = meshgrid(lon_sat, lat_sat);

% SMAP plot
ax1 = subplot('Position', [0.05 .55 .2 .4]); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

% Convert lat/lon to figure (axis) coordinates
[lon2, lat2] = meshgrid(lon_sat, lat_sat);
[x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
vari_sat(vari_sat < climit(1)) = climit(1);
[cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(ax1, color)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')

title(['(a) SMAP clim. of Jul SSS'])

plabel('FontSize', 12)
mlabel off

% SMAP std
ax3 = subplot('Position', [0.05 .10 .2 .4]); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

std_sat(std_sat < climit2(1)) = climit2(1);
[cs, T] = contourf(x, y, std_sat, contour_interval2, 'LineColor', 'none');
caxis(climit2)
colormap(ax3, color2)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')

title(['(c) SMAP std. of Jul SSS'])

plabel('FontSize', 12)
mlabel('FontSize', 12)

% SMOS SSS
si = 2;
% CEC SMOS v9.0
filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/climate/'];

% Satellite
filepath_sat = filepath_CEC;
filepattern1_sat = fullfile(filepath_sat, (['*climate_', mstr, '*.nc']));

filename_sat = dir(filepattern1_sat);
if isempty(filename_sat)
    filename_sat = dir(filepattern2_sat);
end

file_sat = [filepath_sat, filename_sat.name];
lon_sat = double(ncread(file_sat,lons_sat{si}));
lat_sat = double(ncread(file_sat,lats_sat{si}));
vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

file_std = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/std/SMOS_L3_DEBIAS_LOCEAN_AD_std_', mstr, '_EASE_09d_25km_v09.nc'];
std_sat = double(squeeze(ncread(file_std,varis_sat{si}))');

index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
std_sat = [std_sat(:,index1) std_sat(:,index2)];

lon_sat = lon_sat - lons_360ind(si);

latind = find(40<lat_sat & lat_sat <80);
lonind = find(-250<lon_sat & lon_sat <-100);
lat_sat = lat_sat(latind);
lon_sat = lon_sat(lonind);
vari_sat = vari_sat(latind,lonind);
std_sat = std_sat(latind,lonind);
[lon2, lat2] = meshgrid(lon_sat, lat_sat);

% SMOS plot
ax2 = subplot('Position', [.25 .55 .2 .4]); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

% Convert lat/lon to figure (axis) coordinates
[x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
vari_sat(vari_sat < climit(1)) = climit(1);
[cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(ax2, color)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')

title(['(b) SMOS clim. of Jul SSS'])

c = colorbar('Position', [.45 .55 .01 .4]);
c.Title.String = unit;
c.FontSize = 12;

plabel off
mlabel off

% SMOS std
ax4 = subplot('Position', [0.25 .10 .2 .4]); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

std_sat(std_sat < climit2(1)) = climit2(1);
[cs, T] = contourf(x, y, std_sat, contour_interval2, 'LineColor', 'none');
caxis(climit2)
colormap(ax4, color2)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')

title(['(d) SMOS std. of Jul SSS'])

c = colorbar('Position', [.45 .10 .01 .4]);
c.Title.String = unit;
c.FontSize = 12;

plabel off
mlabel('FontSize', 12)
dd
exportgraphics(gcf,'figure_SSS_climate_and_std.png','Resolution',150) 