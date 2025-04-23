%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSS with sea ice concentration
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2019:2022;
plusind = yyyy_all(1) - 2015;
mm = 10;
mstr = num2str(mm, '%02i');

remove_climate = 0;

color = 'jet';
climit = [31.5 33.5];
unit = 'psu';

savename = 'SSS';

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/'];

mm_sea_ice = 6; msistr = num2str(mm_sea_ice, '%02i');
cutoff = 0.15; % 15 %
color_ice = 'm';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, ['ROMS SSS with sea ice concentration (15%) in ', datestr(datenum(0,mm_sea_ice,1), 'mmm')], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';

    if remove_climate == 1
        filepath_climate = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/climate/'];
        filename_climate = ['Dsm2_spng_climate_', mstr, '.nc'];
        file_climate = [filepath_climate, filename_climate];
        vari_climate = ncread(file_climate, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';

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

    if yyyy ~= 2018
    % Sea ice concentration
    filename_ice = ['Dsm2_spng_', ystr, msistr, '.nc'];
    file_ice = [filepath, filename_ice];
    aice_ice = ncread(file_ice, 'aice')';
    aice_ice(isnan(aice_ice) == 1) = 0;

    p = contourm(g.lat_rho, g.lon_rho, aice_ice, [cutoff, cutoff], color_ice, 'LineWidth', 2);
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_aice_', msistr, '_monthly'],'-dpng');