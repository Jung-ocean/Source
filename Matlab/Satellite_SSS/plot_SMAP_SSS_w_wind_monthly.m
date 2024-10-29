%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMAP SSS with wind
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 8;
mstr = num2str(mm, '%02i');

remove_climate = 0;

color = 'jet';
climit = [31.5 33.5];
unit = 'psu';

lons_sat = {'lon'};
lons_360ind = [360];
lats_sat = {'lat'};
varis_sat = {'sss_smap'};
titles_sat = 'RSS SMAP SSS';

savename = 'RSS_SMAP_SSS';

ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 10;
scale_wind = 0.02;
color_wind = 'k';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, [titles_sat, ' with wind'], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
   
    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/monthly/', ystr, '/'];

    % Satellite
    for si = 1:1
        filepath_sat = filepath_RSS_70;
        filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
        filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

        filename_sat = dir(filepattern1_sat);
        if isempty(filename_sat)
            filename_sat = dir(filepattern2_sat);
        end

        file_sat = [filepath_sat, filename_sat.name];
        lon_sat = double(ncread(file_sat,lons_sat{si}));
        lat_sat = double(ncread(file_sat,lats_sat{si}));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

        if remove_climate == 1
            filepath_climate = '/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/climate/';
            filename_climate = ['RSS_smap_SSS_L3_monthly_climate_', mstr, '_FNL_v05.3.nc'];
            file_climate = [filepath_climate, filename_climate];
            vari_climate = double(squeeze(ncread(file_climate,varis_sat{si}))');

            vari_sat = vari_sat - vari_climate;

            color = 'redblue';
            climit = [-1 1];
            title(t, [titles_sat, 'A with wind'], 'FontSize', 25);
            savename = 'RSS_SMAP_SSSA';
        end

        lon_sat = lon_sat - lons_360ind(si);

        % Tile
        nexttile(yi); hold on;

        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
       
        T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
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

%         q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
%             ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
%             ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
%             ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
%             0);
%         q(1).Color = color_wind;
%         q(2).Color = color_wind;

        [xscale, yscale] = mfwdtran(63.5, 155);  % Convert lat/lon to projected x, y coordinates
        qscale = quiver(xscale, yscale, 5.*scale_wind, 0.*scale_wind, 0, 'MaxHeadSize', 0.5, 'Color', 'r', 'AutoScale', 'off');
        [xtscale, ytscale] = mfwdtran(62.5, 155);  % Convert lat/lon to projected x, y coordinates
        text(xtscale, ytscale, '5 m/s', 'Color', 'r', 'FontSize', 12);

%         qscale = quiverm(63.5, 155, 0.*scale_wind, 5.*scale_wind, 0);
%         qscale(1).Color = 'r';
%         qscale(2).Color = 'r';
%         tscale = textm(62.5, 155, '5 m/s', 'Color', 'r', 'FontSize', 12);
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_wind_monthly'],'-dpng');