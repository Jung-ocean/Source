%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot wind monthly using ECMWF ERA5
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';
g = grd('BSf');

yyyy_all = 2019:2022;
mm = 8;
mstr = num2str(mm, '%02i');

ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
        
        interval_wind = 4;
        scale_wind = 0.5;

        scale = 3;
        scale_lat = 64;
        scale_lon = -184.5;
        scale_text = '3 m/s';
        scale_text_lat = 63.5;
        scale_text_lon = -184.5;
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

% Figure properties
savename = 'wind';

figure;
if strcmp(map, 'NE_Pacific')
    set(gcf, 'Position', [1 200 1900 450])
else
    set(gcf, 'Position', [1 200 1500 450])
end
t = tiledlayout(1,4);

title(t, ['10 m wind'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'));
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_uwind = ncread(ERA5_file, 'u10')';
    ERA5_vwind = ncread(ERA5_file, 'v10')';
    %         speed = sqrt(ERA5_uwind.*ERA5_uwind + ERA5_vwind.*ERA5_vwind);
    %         sustr = rhoair.*Cd.*speed.*ERA5_uwind;
    %         svstr = rhoair.*Cd.*speed.*ERA5_vwind;

    latind = find(ERA5_lat < max(max(g.lat_rho)) & ERA5_lat > min(min(g.lat_rho)));
    lonind = find(ERA5_lon-360 < max(max(g.lon_rho)) & ERA5_lon-360 > min(min(g.lon_rho)));
    ERA5_uwind = ERA5_uwind(latind, lonind);
    ERA5_vwind = ERA5_vwind(latind, lonind);

    [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon(lonind)), double(ERA5_lat(latind)));

%     % Convert lat/lon to figure (axis) coordinates
%     [x, y] = mfwdtran(ERA5_lat2, ERA5_lon2);
%     q = quiver(x(1:interval_wind:end, 1:interval_wind:end), ...
%         y(1:interval_wind:end, 1:interval_wind:end), ...
%         ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
%         ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
%         0);
    q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        0);
    q(1).Color = 'k';
    q(2).Color = 'k';
    q(1).LineWidth = 2;
    q(2).LineWidth = 2;
    uistack(q, 'bottom')
    
%     % Convert lat/lon to figure (axis) coordinates
%     [xscale, yscale] = mfwdtran(scale_lat, scale_lon);
%     qscale = quiver(xscale, yscale, scale.*scale_wind, 0.*scale_wind, 0);
    qscale = quiverm(scale_lat, scale_lon, 0.*scale_wind, scale.*scale_wind, 0);
    qscale(1).Color = 'r';
    qscale(2).Color = 'r';
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
%     qscale.MaxHeadSize = 1;

%     % Convert lat/lon to figure (axis) coordinates
%     [xscale_text, yscale_text] = mfwdtran(scale_text_lat, scale_text_lon);
%     tscale = text(xscale_text, yscale_text, scale_text, 'Color', 'r', 'FontSize', 10);
    tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', 10);

    if strcmp(map, 'Gulf_of_Anadyr')
        t1 = textm(text1_lat, text1_lon, 'ERA5', 'FontSize', text_FS)
        t2 = textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
    else
        title(['ROMS (', title_str, ')'])
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');