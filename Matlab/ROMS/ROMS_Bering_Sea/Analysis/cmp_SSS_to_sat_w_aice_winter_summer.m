%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSS in winter and summer
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
seasons = {'winter', 'summer'};
titles = {'JFM', 'JAS'};

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/winter_summer/'];

% Satellite
lons_sat = {'lon', 'lon'};
lons_360ind = [360 180];
lats_sat = {'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS'};
titles_sat = {'RSS SMAP SSS', 'CEC SMOS SSS'};

% Figure properties
color = 'jet';
climit = [31 34];
contour_interval = climit(1):0.3:climit(2);
unit = 'psu';
savename = 'SSS';

figure;
set(gcf, 'Position', [1 200 1500 700])
t = tiledlayout(2,3);
% Figure title
title(t, ['SSS in winter (top) and summer (bottom)'], 'FontSize', 25);

for i = 1:length(seasons)
        season = seasons{i};

    filename = ['Dsm2_spng_', season, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';
   
    % ROMS plot
    if strcmp(season, 'summer')
        nexttile(i+2); hold on;
    else
        nexttile(i); hold on;
    end

    plot_map(map, 'mercator', 'l')
%     contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T = pcolorm(g.lat_rho,g.lon_rho,vari); shading flat
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
    vari(isnan(vari) == 1) = 0;
    contourm(g.lat_rho, g.lon_rho, vari, contour_interval, 'k');

    title(['ROMS (', titles{i}, ', 2019-2022)'])

    % SMAP SSS
    si = 1;
    % RSS SMAP v6.0
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/winter_summer/'];

    filepath_sat = filepath_RSS_70;
    filepattern1_sat = fullfile(filepath_sat, (['*', season, '*.nc']));

    filename_sat = dir(filepattern1_sat);
    if isempty(filename_sat)
        filename_sat = dir(filepattern2_sat);
    end

    file_sat = [filepath_sat, filename_sat.name];
    lon_sat = double(ncread(file_sat,lons_sat{si}));
    lat_sat = double(ncread(file_sat,lats_sat{si}));
    vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
   
    lon_sat = lon_sat - lons_360ind(si);

    % SMAP plot
    if strcmp(season, 'summer')
        nexttile(i+1+2); hold on;
    else
        nexttile(i+1); hold on;
    end

    plot_map(map, 'mercator', 'l')
%     contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
    vari_sat(isnan(vari_sat) == 1) = 0;
    contourm(lat_sat, lon_sat, vari_sat, contour_interval, 'k');

    title(['RSS SMAP L3 (', titles{i}, ', 2015-2023)'])

    % SMOS SSS
    si = 2;
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/winter_summer/'];

    % Satellite
    filepath_sat = filepath_CEC;
    filepattern1_sat = fullfile(filepath_sat, (['*', season, '*.nc']));

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

    % SMOS plot
    if strcmp(season, 'summer')
        nexttile(i+2+2); hold on;
    else
        nexttile(i+2); hold on;
    end

    plot_map(map, 'mercator', 'l')
%     contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
    vari_sat(isnan(vari_sat) == 1) = 0;
    contourm(lat_sat, lon_sat, vari_sat, contour_interval, 'k');

    title(['CEC SMOS L3 (', titles{i}, ', 2011-2023)'])

    if i == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.FontSize = 15;
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';
fff
print([savename, '_winter_summer'],'-dpng');