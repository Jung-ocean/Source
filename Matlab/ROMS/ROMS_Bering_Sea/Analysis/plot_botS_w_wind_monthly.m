%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS botS with wind
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2019:2022;
plusind = yyyy_all(1) - 2015;
mm = 8;
mstr = num2str(mm, '%02i');

is200 = 1;
remove_climate = 0;

color = 'jet';
climit = [31.5 33.5];
unit = 'psu';

savename = 'botS';

ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 10;
scale_wind = 0.02;
color_wind = 'k';

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/'];

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, ['ROMS botS with wind'], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt', [1 1 1 1], [Inf Inf 1 Inf])';

    if is200 == 1
        layer = -200;
        zeta = ncread(file, 'zeta')';
        z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);

        var_sigma = squeeze(ncread(file, vari_str));
        var_sigma = permute(var_sigma, [3 2 1]);
        vari200 = vinterp(var_sigma,z,layer);

        index = find(isnan(vari200) == 1);
        vari200(index) = vari(index);
        vari = vari200;

        title(t, ['ROMS bottom or 200 m salinity with wind'], 'FontSize', 25);
        savename = 'botS_or_200m';
    end

    if remove_climate == 1
        filepath_climate = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/climate/'];
        filename_climate = ['Dsm2_spng_climate_', mstr, '.nc'];
        file_climate = [filepath_climate, filename_climate];
        vari_climate = ncread(file_climate, 'salt', [1 1 1 1], [Inf Inf 1 Inf])';

        vari = vari - vari_climate;

        color = 'redblue';
        climit = [-1 1];
        title(t, ['ROMS SSSA with sea ice concentration (15%) in ', datestr(datenum(0,mm_sea_ice,1), 'mmm')], 'FontSize', 25);
        savename = 'SSSA';
        color_ice = 'g';
    end

    % Tile
    nexttile(yi+plusind); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T = pcolorm(g.lat_rho,g.lon_rho,vari); shading flat
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')

    if yi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.FontSize = 15;
    end

    textm(65, -205, [title_str], 'FontSize', 20)

    % Wind
    ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];

    ERA5_lon = ncread(ERA5_file, 'longitude');
    ERA5_lat = ncread(ERA5_file, 'latitude');
    ERA5_uwind = ncread(ERA5_file, 'u10')';
    ERA5_vwind = ncread(ERA5_file, 'v10')';

    [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon), double(ERA5_lat));

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(ERA5_lat2, ERA5_lon2);  % Convert lat/lon to projected x, y coordinates

    % Draw arrows
    q = quiver(x(1:interval_wind:end, 1:interval_wind:end), ...
        y(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        0, 'MaxHeadSize', 0.5, 'Color', 'k', 'LineWidth', 1, 'AutoScale', 'off');

    [xscale, yscale] = mfwdtran(63.5, 155);  % Convert lat/lon to projected x, y coordinates
    qscale = quiver(xscale, yscale, 5.*scale_wind, 0.*scale_wind, 0, 'MaxHeadSize', 0.5, 'Color', 'r', 'AutoScale', 'off');
    [xtscale, ytscale] = mfwdtran(62.5, 155);  % Convert lat/lon to projected x, y coordinates
    text(xtscale, ytscale, '5 m/s', 'Color', 'r', 'FontSize', 12);
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_wind_monthly'],'-dpng');