%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot CMEMS L4 ADT monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'adt';
yyyy_all = 2015:2022;
mm = 4;
mstr = num2str(mm, '%02i');

remove_climate = 0;

color = 'jet';
climit = [-40 40];
contour_interval = climit(1):5:climit(2);

unit = 'cm';

savename = 'CMEMS_ADT';

filepath_CMEMS = '/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, ['CMEMS ADT (interval = 5cm)'], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % Satellite L4
    filename_CMEMS = ['dt_global_allsat_phy_l4_', ystr, mstr, '.nc'];
    file_CMEMS = [filepath_CMEMS, filename_CMEMS];

    lon_sat = double(ncread(file_CMEMS,'longitude'));
    lat_sat = double(ncread(file_CMEMS,'latitude'));
    vari_sat = 100*double(squeeze(ncread(file_CMEMS,'adt'))');

    vari_mean = mean(vari_sat(:), 'omitnan');
    vari_sat = vari_sat - vari_mean;

    if remove_climate == 1
        filepath_climate = '/data/jungjih/Observations/Satellite_SSH/CMEMS/climate_8years/';
        filename_climate = ['dt_global_allsat_phy_l4_climate_', mstr, '.nc'];
        file_climate = [filepath_climate, filename_climate];
        vari_climate = 100*double(squeeze(ncread(file_climate,'adt'))');

%         vari_climate = vari_climate - mean(vari_climate(:), 'omitnan');
    
        vari_sat = vari_sat + vari_mean;
        vari_sat = vari_sat - vari_climate;

        color = 'redblue';
        climit = [-10 10];
        contour_interval = climit(1):2:climit(2);
        title(t, ['CMEMS ADT anomaly (interval = 2cm)'], 'FontSize', 25);
        savename = 'CMEMS_ADT_anomaly';
    end

    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
    lon_sat = lon_sat - 180;

    % Tile
    nexttile(yi); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
    
    vari_sat(isnan(vari_sat) == 1) = -1000;
    contourm(lat_sat,lon_sat,vari_sat, contour_interval, 'k');

    if yi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.FontSize = 15;
    end

    textm(65, -205, [title_str], 'FontSize', 20)

end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');