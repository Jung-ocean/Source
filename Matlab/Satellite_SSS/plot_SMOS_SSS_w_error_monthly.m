%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMOS SSS with error
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 8;
mstr = num2str(mm, '%02i');

iserr = 1;
remove_climate = 0;

climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
color_err = 'k';
unit = 'psu';

lons_sat = {'lon'};
lons_360ind = [180];
lats_sat = {'lat'};
varis_sat = {'SSS'};
titles_sat = 'CEC SMOS SSS';

savename = 'CEC_SMOS_SSS';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, [titles_sat, ' with error'], 'FontSize', 25);

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
        err_sat = double(squeeze(ncread(file_sat,'eSSS'))');

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

            title(t, [titles_sat, 'A with error'], 'FontSize', 25);
            savename = 'CEC_SMOS_SSSA';
            color_ice = 'g';
        end

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
        err_sat = [err_sat(:,index1) err_sat(:,index2)];

        lon_sat = lon_sat - lons_360ind(si);

        latind = find(40 < lat_sat & lat_sat <80);
        lonind = find(-250 < lon_sat & lon_sat < -100);
        lat_sat = lat_sat(latind);
        lon_sat = lon_sat(lonind);
        vari_sat = vari_sat(latind,lonind);
        err_sat = err_sat(latind,lonind);
        [lon2, lat2] = meshgrid(lon_sat, lat_sat);

        % Tile
        nexttile(yi); hold on;

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
        
        if yi == 1
            c = colorbar;
            c.Layout.Tile = 'east';
            c.Title.String = unit;
            c.FontSize = 15;
        end
        
        if strcmp(map, 'Gulf_of_Anadyr')
            textm(65.9, -178, [title_str], 'FontSize', 15)
            set(gcf, 'Position', [1 200 1100 900])
        else
            textm(65, -205, [title_str], 'FontSize', 20)
        end

        if iserr == 1
            % SSS error
            [cs, h] = contour(x, y, err_sat, [0:0.2:1], color_err, 'LineWidth', 2);
            clabel(cs, h, 'FontSize', 15)
        else
            if remove_climate == 1
                title(t, [titles_sat, 'A'], 'FontSize', 25);
            else
                title(t, [titles_sat], 'FontSize', 25);
            end
        end
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_error_monthly'],'-dpng');