%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMAP SSS with sea ice concentration
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

vari_str = 'salt';
yyyy_all = 2015:2023;

mm_all = 1:12;
for mi = 1:length(mm_all)

mm = mm_all(mi);
mstr = num2str(mm, '%02i');

isice = 0;
remove_climate = 1;
issave = 0;

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

filepath_ASI = '/data/jungjih/Observations/Sea_ice/ASI/monthly_ROMSgrid/';
mm_sea_ice = 6; msistr = num2str(mm_sea_ice, '%02i');
cutoff = 0.15; % 15 %
color_ice = 'm';

% Load grid information
g = grd('BSf');

figure;
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(3,3);
% Figure title
title(t, [titles_sat, ' with ASI sea ice concentration (15%) in ', datestr(datenum(0,mm_sea_ice,1), 'mmm')], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
   
    % Satellite SSS
    % RSS SMAP v6.0
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/RSS/v6.0/monthly/', ystr, '/'];

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
        try
        lon_sat = double(ncread(file_sat,lons_sat{si}));
        lat_sat = double(ncread(file_sat,lats_sat{si}));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
        catch
            lon_sat = NaN;
            lat_sat = NaN;
            vari_sat = NaN;
        end

        if remove_climate == 1
            filepath_climate = '/data/jungjih/Observations/Satellite_SSS/RSS/v6.0/climate/';
            filename_climate = ['RSS_smap_SSS_L3_climate_', mstr, '_FNL_v06.0.nc'];
            file_climate = [filepath_climate, filename_climate];
            vari_climate = double(squeeze(ncread(file_climate,varis_sat{si}))');

            vari_sat = vari_sat - vari_climate;

            %climit = [-2 2]; interval = 0.5;
            climit = [-1 1]; interval = 0.2;
            contour_interval = climit(1):interval:climit(2);
            num_color = diff(climit)/interval;
            color_tmp = redblue;
            color = color_tmp(linspace(1,length(color_tmp),num_color),:);

            title(t, [titles_sat, 'A with ASI sea ice concentration (15%) in ', datestr(datenum(0,mm_sea_ice,1), 'mmm')], 'FontSize', 25);
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

        if issave == 1
            save(['SMAP_SSSA_', datestr(datenum(yyyy,mm,1), 'yyyymm'), '.mat'], 'lon_sat', 'lat_sat', 'vari_sat')
        end

        % Tile
        nexttile(yi); hold on;

        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
       
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
        elseif strcmp(map, 'NW_Bering')
            textm(65, -198, [title_str], 'FontSize', 15)
        else
            textm(65, -205, [title_str], 'FontSize', 20)
        end

        if isice == 1
            % Sea ice concentration
            filename_ASI = ['asi-AMSR2-n6250-', ystr, msistr, '-v5.4.nc'];
            file_ASI = [filepath_ASI, filename_ASI];
            aice_ASI = ncread(file_ASI, 'z')'/100;
            aice_ASI(isnan(aice_ASI) == 1) = 0;

            p = contourm(g.lat_rho, g.lon_rho, aice_ASI, [cutoff, cutoff], color_ice, 'LineWidth', 2);
        else
            if remove_climate == 1
                title(t, [titles_sat, 'A'], 'FontSize', 25);
            else
                title(t, [titles_sat], 'FontSize', 25);
            end
            msistr = '00';
        end
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_with_aice_', msistr, '_monthly'],'-dpng');


end