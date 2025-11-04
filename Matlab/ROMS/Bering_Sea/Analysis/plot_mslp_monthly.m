%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot MSLP monthly using ECMWF ERA5
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';
[lon, lat] = load_domain(map);

vari_str = 'msl';
yyyy_all = 2019:2022;
mm = 5;
mstr = num2str(mm, '%02i');

ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';

iswind = 0;

switch map
    case 'Eastern_Bering'
        interval_wind = 5;
        scale_wind = 15;

        scale = 0.2;
        scale_lat = 66;
        scale_lon = -184.5;
        scale_text = '0.2 N/m^2';
        scale_text_lat = 65.5;
        scale_text_lon = -184.5;
    case 'NE_Pacific'
        interval_wind = 10;
        scale_wind = 40;

        scale = 0.2;
        scale_lat = 66;
        scale_lon = -205;
        scale_text = '0.2 N/m^2';
        scale_text_lat = 64;
        scale_text_lon = -205;
end
Cd = 1.25e-3;
rhoair = 1.225;

% Figure properties
climit = [990 1030];
interval = 2;
[color, contour_interval] = get_color('jet', climit, interval);
% contour_interval = climit(1):4:climit(2);
unit = 'hPa';
savename = 'mslp';

figure;
if strcmp(map, 'NE_Pacific')
    set(gcf, 'Position', [1 200 1900 450])
else
    set(gcf, 'Position', [1 200 1800 500])
end

t = tiledlayout(1,4);
title(t, {'ERA5 mean sea level pressure', ''}, 'FontSize', 20)

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'))-360;
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_msl = double(ncread(ERA5_file, vari_str))/100;

    lonind = find(ERA5_lon > lon(1)-1 & ERA5_lon < lon(2)+1);
    latind = find(ERA5_lat > lat(1)-1 & ERA5_lat < lat(2)+1);
    [lat2, lon2] = meshgrid(ERA5_lat(latind), ERA5_lon(lonind));
    ERA5_msl_part = ERA5_msl(lonind, latind);

    nexttile(yi); hold on;
    plot_map(map, 'mercator', 'l')
%     p = pcolorm(ERA5_lat, ERA5_lon, ERA5_msl); shading flat
    p = plot_contourf([], lat2, lon2, ERA5_msl_part, color, climit, contour_interval);
    p.LineColor = 'k';

%     [cs, h] = contourm(ERA5_lat, ERA5_lon, ERA5_msl, contour_interval, 'k');
%     cl = clabelm(cs, h);
%     set(cl,'BackgroundColor', 'none', 'Edgecolor', 'none')
    title([title_str], 'FontSize', 15)

    if iswind == 1
        ERA5_uwind = ncread(ERA5_file, 'u10')';
        ERA5_vwind = ncread(ERA5_file, 'v10')';
        speed = sqrt(ERA5_uwind.*ERA5_uwind + ERA5_vwind.*ERA5_vwind);
        sustr = rhoair.*Cd.*speed.*ERA5_uwind;
        svstr = rhoair.*Cd.*speed.*ERA5_vwind;

        [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon), double(ERA5_lat));

        q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
            svstr(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            sustr(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            0);
        q(1).Color = 'k';
        q(2).Color = 'k';
        q(1).LineWidth = 2;
        q(2).LineWidth = 2;

        qscale = quiverm(scale_lat, scale_lon, 0.*scale_wind, scale.*scale_wind, 0);
        qscale(1).Color = 'r';
        qscale(2).Color = 'r';
        tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', 10);

        title(['ERA5 MSLP with neutral wind stress (', title_str, ')'])
        savename = 'mslp_with_windstress';
    end

    if yi == 4
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = climit(1):interval*2:climit(end);
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', mstr, '_monthly'],'-dpng');