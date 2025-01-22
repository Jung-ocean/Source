clear; clc; close all

map = 'Gulf_of_Anadyr';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 7;
mstr = num2str(mm, '%02i');

isice = 0;
remove_climate = 1;

climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';

lons_sat = {'lon'};
lons_360ind = [360];
lats_sat = {'lat'};
varis_sat = {'sss_smap'};
titles_sat = 'RSS SMAP SSS';

savename = 'RSS_SMAP_SSS';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1800 900])
% Figure title

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
   
    % Satellite SSS
    % RSS SMAP v6.0
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/monthly/', ystr, '/'];

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
            filepath_climate = '/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/climate/';
            filename_climate = ['RSS_smap_SSS_L3_monthly_climate_', mstr, '_FNL_v06.0.nc'];
            file_climate = [filepath_climate, filename_climate];
            vari_climate = double(squeeze(ncread(file_climate,varis_sat{si}))');

            vari_sat = vari_sat - vari_climate;

            climit = [-2 2];
            interval = 0.5;
            contour_interval = climit(1):interval:climit(2);
            num_color = diff(climit)/interval;
            color_tmp = redblue;
            color = color_tmp(linspace(1,length(color_tmp),num_color),:);

            savename = 'RSS_SMAP_SSSA';
            color_ice = 'g';
        end

        lon_sat = lon_sat - lons_360ind(si);

        latind = find(40 < lat_sat & lat_sat <80);
        lonind = find(-250 < lon_sat & lon_sat < -100);
        lat_sat = lat_sat(latind);
        lon_sat = lon_sat(lonind);
        vari_sat = vari_sat(latind,lonind);
        [lon2, lat2] = meshgrid(lon_sat, lat_sat);

        % Tile
        if yi < 4
            subplot('Position', [.02 + .15*(yi-1) .7 .15 .25]); hold on;
        elseif yi > 3 & yi < 7
            subplot('Position', [.02 + .15*(yi-4) .4 .15 .25]); hold on;
        else
            subplot('Position', [.02 + .15*(yi-7) .1 .15 .25]); hold on;
        end

        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
       
        % Convert lat/lon to figure (axis) coordinates
        [x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
        vari_sat(vari_sat < climit(1)) = climit(1);
        vari_sat(vari_sat > climit(2)) = climit(2);
        [cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
        caxis(climit)
        colormap(color)
        uistack(T,'bottom')
        plot_map(map, 'mercator', 'l')
                
        textm(65.9, -184.6, 'SMAP', 'FontSize', 15)
        textm(65.9, -178, [title_str], 'FontSize', 15)
            
        if yi < 4
            if yi ~= 1
                plabel off
            end
            mlabel off
        elseif yi > 3 & yi < 7
            if yi ~= 4
                plabel off
            end
            mlabel off
        else
            if yi ~= 7
                plabel off
            end
        end
           
    end
end % yi

% SMOS
lons_sat = {'lon'};
lons_360ind = [180];
lats_sat = {'lat'};
varis_sat = {'SSS'};
titles_sat = 'CEC SMOS SSS';

savename = 'CEC_SMOS_SSS';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
   
    % Satellite SSS
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];

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
            filepath_climate = '/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/climate/';
            filename_climate = ['SMOS_L3_DEBIAS_LOCEAN_AD_climate_', mstr, '_EASE_09d_25km_v09.nc'];
            file_climate = [filepath_climate, filename_climate];
            vari_climate = double(squeeze(ncread(file_climate,varis_sat{si}))');

            vari_sat = vari_sat - vari_climate;

            climit = [-2 2];
            interval = 0.5;
            contour_interval = climit(1):interval:climit(2);
            num_color = diff(climit)/interval;
            color_tmp = redblue;
            color = color_tmp(linspace(1,length(color_tmp),num_color),:);
        end

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

        lon_sat = lon_sat - lons_360ind(si);

        latind = find(40 < lat_sat & lat_sat <80);
        lonind = find(-250 < lon_sat & lon_sat < -100);
        lat_sat = lat_sat(latind);
        lon_sat = lon_sat(lonind);
        vari_sat = vari_sat(latind,lonind);
        [lon2, lat2] = meshgrid(lon_sat, lat_sat);

        % Tile
        if yi < 4
            subplot('Position', [.50 + .15*(yi-1) .7 .15 .25]); hold on;
        elseif yi > 3 & yi < 7
            subplot('Position', [.50 + .15*(yi-4) .4 .15 .25]); hold on;
        else
            subplot('Position', [.50 + .15*(yi-7) .1 .15 .25]); hold on;
        end

        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
       
        %         T = pcolorm(lat_sat,lon_sat,vari_sat); shading flat
        % Convert lat/lon to figure (axis) coordinates
        [x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
        vari_sat(vari_sat < climit(1)) = climit(1);
        vari_sat(vari_sat > climit(2)) = climit(2);
        [cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
        caxis(climit)
        colormap(color)
        uistack(T,'bottom')
        plot_map(map, 'mercator', 'l')
        
%         if yi == 1
%             c = colorbar;
%             c.Layout.Tile = 'east';
%             c.Title.String = unit;
%             c.FontSize = 15;
%         end
        
        textm(65.9, -184.6, 'SMOS', 'FontSize', 15)
        textm(65.9, -178, [title_str], 'FontSize', 15)

            if yi < 4
                if yi ~= 1
                    plabel off
                end
                mlabel off
            elseif yi > 3 & yi < 7
                if yi ~= 4
                    plabel off
                end
                mlabel off
            else
                if yi ~= 7
                    plabel off
                end
            end
        
    end
end % yi

c = colorbar('Position', [.96 .1 .01 .85]);
c.Title.String = unit;
c.FontSize = 12;

exportgraphics(gcf,'figure_SSSA_SMAP_SMOS.png','Resolution',150) 