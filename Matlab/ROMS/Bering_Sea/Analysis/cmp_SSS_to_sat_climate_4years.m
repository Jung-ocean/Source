%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS climate SSS to satellite products (4years)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'salt';
mm = 8;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/climate/'];

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

figure;
set(gcf, 'Position', [1 200 1300 430])
t = tiledlayout(1,3);
% Figure title
title(t, ['Clim. SSS in ', datestr(datenum(0,mm,15), 'mmm')], 'FontSize', 25);


filename = [exp, '_climate_', mstr, '.nc'];
file = [filepath, filename];
vari = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';

% ROMS plot
nexttile(3); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

% T = pcolorm(g.lat_rho,g.lon_rho,vari); shading flat
% Convert lat/lon to figure (axis) coordinates
[x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
vari(vari < climit(1)) = climit(1);
[cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(color)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')
% vari(isnan(vari) == 1) = 0;
% contourm(g.lat_rho, g.lon_rho, vari, contour_interval, 'k');

title(['ROMS (2019-2022)'])

% SMAP SSS
si = 1;
% RSS SMAP v6.0
filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/climate_4years/'];

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

lon_sat = lon_sat - lons_360ind(si);

latind = find(40<lat_sat & lat_sat <80);
lonind = find(-250<lon_sat & lon_sat <-100);
lat_sat = lat_sat(latind);
lon_sat = lon_sat(lonind);
vari_sat = vari_sat(latind,lonind);
[lon2, lat2] = meshgrid(lon_sat, lat_sat);

% SMAP plot
nexttile(1); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

% T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
% Convert lat/lon to figure (axis) coordinates
[lon2, lat2] = meshgrid(lon_sat, lat_sat);
[x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
vari_sat(vari_sat < climit(1)) = climit(1);
[cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(color)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')
% vari_sat(isnan(vari_sat) == 1) = 0;
% contourm(lat_sat, lon_sat, vari_sat, contour_interval, 'k');

title(['RSS SMAP L3 (2019-2022)'])
% title(['RSS SMAP L3 (2019-2022)'])

% SMOS SSS
si = 2;
% CEC SMOS v9.0
filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/climate_4years/'];

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

index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

lon_sat = lon_sat - lons_360ind(si);

latind = find(40<lat_sat & lat_sat <80);
lonind = find(-250<lon_sat & lon_sat <-100);
lat_sat = lat_sat(latind);
lon_sat = lon_sat(lonind);
vari_sat = vari_sat(latind,lonind);
[lon2, lat2] = meshgrid(lon_sat, lat_sat);

% SMOS plot
nexttile(2); hold on;
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

% T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
% Convert lat/lon to figure (axis) coordinates
[x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
vari_sat(vari_sat < climit(1)) = climit(1);
[cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
caxis(climit)
colormap(color)
uistack(T,'bottom')
plot_map(map, 'mercator', 'l')
% vari_sat(isnan(vari_sat) == 1) = 0;
% contourm(lat_sat, lon_sat, vari_sat, contour_interval, 'k');

title(['CEC SMOS L3 (2019-2022)'])
% title(['CEC SMOS L3 (2019-2022)'])

c = colorbar;
c.Layout.Tile = 'east';
c.Title.String = unit;
c.FontSize = 15;

t.Padding = 'compact';
t.TileSpacing = 'compact';
set(gcf, 'Position', [1 200 1300 430])

print([savename, '_climate_', mstr],'-dpng');