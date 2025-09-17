%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMOS SSS with SLA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 8;
mstr = num2str(mm, '%02i');

remove_climate = 1;

color = 'jet';
climit = [29 33];
unit = 'psu';

lons_sat = {'lon'};
lons_360ind = [180];
lats_sat = {'lat'};
varis_sat = {'SSS'};
titles_sat = 'CEC SMOS SSS';

savename = 'CEC_SMOS_SSS';

SSH_filepath = '/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly_tmp/';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, [titles_sat, ' with SLA'], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
   
    % Satellite SSS
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/CEC/v9/monthly/'];

    % Satellite
    for si = 1:1
        filepath_sat = filepath_CEC;
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
            filepath_climate = '/data/jungjih/Observations/Satellite_SSS/CEC/v9/climate/';
            filename_climate = ['SMOS_L3_DEBIAS_LOCEAN_AD_climate_', mstr, '_EASE_09d_25km_v09.nc'];
            file_climate = [filepath_climate, filename_climate];
            vari_climate = double(squeeze(ncread(file_climate,varis_sat{si}))');

            vari_sat = vari_sat - vari_climate;

            colormap = 'redblue';
            climit = [-1 1];
            interval = 0.2;
            [color, contour_interval] = get_color(colormap, climit, interval);
            clearvars colormap;
            title(t, [titles_sat, 'A with SLA'], 'FontSize', 25);
            savename = 'CEC_SMOS_SSSA';
        end

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

        lon_sat = lon_sat - lons_360ind(si);

        % Tile
        nexttile(yi); hold on;

        plot_map(map, 'mercator', 'l')
%         contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
       
        T = pcolorm(lat_sat,lon_sat,vari_sat);
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
        
        if strcmp(map, 'Gulf_of_Anadyr')
            textm(65.9, -178, [title_str], 'FontSize', 15)
            set(gcf, 'Position', [1 200 1100 900])
        elseif strcmp(map, 'NW_Bering')
            textm(65, -198, [title_str], 'FontSize', 15)
        else
            textm(65, -205, [title_str], 'FontSize', 20)
        end

        % SLA
        SSH_filename = ['dt_global_allsat_msla_h_y', ystr, '_m', mstr, '.nc'];
        SSH_file = [SSH_filepath, '/', ystr, '/', SSH_filename];

        SSH_lon = ncread(SSH_file, 'longitude');
        SSH_lat = ncread(SSH_file, 'latitude');
        SSH = ncread(SSH_file, 'sla');

        index1 = find(SSH_lon > 0); index2 = find(SSH_lon < 0);
        SSH = [SSH(index1,:); SSH(index2,:)];
        SSH_lon = SSH_lon - 180;

        [lon_limit, lat_limit] = load_domain(map);
        lonind = find(SSH_lon > lon_limit(1)-2 & SSH_lon < lon_limit(2)+2);
        latind = find(SSH_lat > lat_limit(1)-2 & SSH_lat < lat_limit(2)+2);
        
        [SSH_lat2, SSH_lon2] = meshgrid(double(SSH_lat(latind)), double(SSH_lon(lonind)));
        SSH = SSH(lonind, latind);
       
        % Plot SSH
        contourm(SSH_lat2, SSH_lon2, SSH, [-3:0.1:3], 'k', 'LineWidth', 1.5);

    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_SLA_monthly'],'-dpng');