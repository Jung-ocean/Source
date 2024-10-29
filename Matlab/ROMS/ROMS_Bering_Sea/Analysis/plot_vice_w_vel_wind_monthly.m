%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sea ice volume (ROMS) with ice velocity (ROMS) 
% and wind (ERA5) monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
map = 'Gulf_of_Anadyr';

yyyy_all = 2019:2022;
mm = 6;
mstr = num2str(mm, '%02i');

g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
area=dx.*dy;

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
vel_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/uvice/'];
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';

switch map
    case 'Gulf_of_Anadyr'
        text_ice_lat = 66.1;
        text_ice_lon = -184.8;

        text_wind_lat = 63.7;
        text_wind_lon = -184.8;
                     
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
        
        color_ice = 'r';
        interval_ice = 30;
        scale_ice = 6;
        scale_ice_value = 0.2;
        scale_ice_lat = text_ice_lat-0.5;
        scale_ice_lon = text_ice_lon;
        scale_ice_text = '20 cm/s';
        scale_ice_text_lat = scale_ice_lat-0.4;
        scale_ice_text_lon = text_ice_lon;

        color_wind = 'k';
        interval_wind = 6;
        scale_wind = 0.5;
        scale_wind_value = 3;
        scale_wind_lat = text_wind_lat-0.5;
        scale_wind_lon = text_wind_lon;
        scale_wind_text = '3 m/s';
        scale_wind_text_lat = scale_wind_lat-0.4;
        scale_wind_text_lon = text_wind_lon;
end

% Figure properties
interval = .4;
climit = [0 2];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
cutoff_hice = 0.1;
fac = 1e6;
unit = ['x10^', num2str(log10(fac)), ' m^3'];
savename = 'vice_w_wind';

figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);

title(t, ['Sea ice volume with sea ice velocity (red) and 10 m wind (black)'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    hice = ncread(file, 'hice')';
    vari = area.*hice/fac;

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

    % Sea ice velocity plot
    vel_filename = ['uvice_hice-weighted_monthly_', ystr, mstr, '.mat'];
    vel_file = [vel_filepath, vel_filename];
    load(vel_file);
    uice_wmean(hice < cutoff_hice) = NaN;
    vice_wmean(hice < cutoff_hice) = NaN;
    
    qice = quiverm(g.lat_rho(1:interval_ice:end, 1:interval_ice:end), ...
        g.lon_rho(1:interval_ice:end, 1:interval_ice:end), ...
        vice_wmean(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
        uice_wmean(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
        0);
    qice(1).Color = color_ice;
    qice(2).Color = color_ice;
    qice(1).LineWidth = 2;
    qice(2).LineWidth = 2;
    
    qscale = quiverm(scale_ice_lat, scale_ice_lon, 0.*scale_ice, scale_ice_value.*scale_ice, 0);
    qscale(1).Color = color_ice;
    qscale(2).Color = color_ice;
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
    tscale = textm(scale_ice_text_lat, scale_ice_text_lon, scale_ice_text, 'Color', color_ice, 'FontSize', 10);

    % Wind plot
    ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'));
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_uwind = ncread(ERA5_file, 'u10')';
    ERA5_vwind = ncread(ERA5_file, 'v10')';

    latind = find(ERA5_lat < max(max(g.lat_rho)) & ERA5_lat > min(min(g.lat_rho)));
    lonind = find(ERA5_lon-360 < max(max(g.lon_rho)) & ERA5_lon-360 > min(min(g.lon_rho)));
    ERA5_uwind = ERA5_uwind(latind, lonind);
    ERA5_vwind = ERA5_vwind(latind, lonind);

    [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon(lonind)), double(ERA5_lat(latind)));

    qwind = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        0);
    qwind(1).Color = color_wind;
    qwind(2).Color = color_wind;
    qwind(1).LineWidth = 2;
    qwind(2).LineWidth = 2;
    
    qscale = quiverm(scale_wind_lat, scale_wind_lon, 0.*scale_wind, scale_wind_value.*scale_wind, 0);
    qscale(1).Color = color_wind;
    qscale(2).Color = color_wind;
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
    tscale = textm(scale_wind_text_lat, scale_wind_text_lon, scale_wind_text, 'Color', color_wind, 'FontSize', 10);

    uistack(qwind, 'bottom')
    uistack(qice, 'bottom')
    uistack(T,'bottom')

    if strcmp(map, 'Gulf_of_Anadyr')
        t1 = textm(text_ice_lat, text_ice_lon, 'Sea ice', 'Color', color_ice, 'FontSize', text_FS);
        t2 = textm(text_wind_lat, text_wind_lon, 'Wind', 'Color', color_wind, 'FontSize', text_FS);

        t3 = textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS);
    else
        title(['ROMS (', title_str, ')'])
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');