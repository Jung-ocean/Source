%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sea ice volume (ROMS) with wind (ERA5) monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
map = 'Gulf_of_Anadyr';
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
area=dx.*dy;

yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
        
        interval_wind = 6;
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
interval = .4;
climit = [0 2];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
fac = 1e6;
unit = ['x10^', num2str(log10(fac)), ' m^3'];
savename = 'vice_w_wind';

figure;
if strcmp(map, 'NE_Pacific')
    set(gcf, 'Position', [1 200 1900 450])
else
    set(gcf, 'Position', [1 200 1500 450])
end
t = tiledlayout(1,4);

title(t, ['Sea ice volume with 10 m wind (vector)'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = area.*ncread(file, 'hice')'/fac;

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);
    [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
    
    if yi == 4
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.Ticks = contour_interval;
    end

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
    uistack(T,'bottom')
    
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
%         t1 = textm(text1_lat, text1_lon, 'ERA5', 'FontSize', text_FS);
        t2 = textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS);
    else
        title(['ROMS (', title_str, ')'])
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');