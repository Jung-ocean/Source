clear; clc; close all

labels_ROMS = {'i', 'j', 'k', 'l'};
labels_SMAP = {'a', 'b', 'c', 'd'};
labels_SMOS = {'e', 'f', 'g', 'h'};

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'salt';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

remove_climate = 1;

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Satellite
lons_sat = {'lon', 'lon'};
lons_360ind = [360 180];
lats_sat = {'lat', 'lat'};
varis_sat = {'sss_smap', 'SSS'};
titles_sat = {'RSS SMAP SSS', 'CEC SMOS SSS'};

% Figure properties
climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';
savename = 'SSS';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

figure;
set(gcf, 'Position', [1 200 1800 900])

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';

    if remove_climate == 1
        filepath_climate = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/climate/'];
        filename_climate = [exp, '_climate_', mstr, '.nc'];
        file_climate = [filepath_climate, filename_climate];
        vari_climate = ncread(file_climate, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf])';

        vari = vari - vari_climate;

        climit = [-2 2];
        interval = 0.5;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color_tmp = redblue;
        color = color_tmp(linspace(1,length(color_tmp),num_color),:);
    end

    % ROMS plot
    subplot('Position', [.02+.16*(yi-1) .1 .15 .25]); hold on;
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels_ROMS{yi}, 'FontSize', 20)

    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    %     T = pcolorm(g.lat_rho,g.lon_rho,vari_surf); shading flat
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(2)) = climit(2);
    [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')

    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
   
    if yi ~= 1
        plabel off
    end

    % SMAP SSS
    si = 1;
    % RSS SMAP v6.0
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/monthly/', ystr, '/'];

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
    end
    lon_sat = lon_sat - lons_360ind(si);

    latind = find(40 < lat_sat & lat_sat <80);
    lonind = find(-250 < lon_sat & lon_sat < -100);
    lat_sat = lat_sat(latind);
    lon_sat = lon_sat(lonind);
    vari_sat = vari_sat(latind,lonind);
    [lon2, lat2] = meshgrid(lon_sat, lat_sat);

    % SMAP plot
    subplot('Position', [.02+.16*(yi-1) .66 .15 .25]); hold on;
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels_SMAP{yi}, 'FontSize', 20)

    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

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

    textm(text1_lat, text1_lon, 'SMAP', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi ~= 1
        plabel off
    end
    mlabel off

    % SMOS SSS
    si = 2;
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];

    % Satellite
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

    % SMOS plot
    subplot('Position', [.02+.16*(yi-1) .38 .15 .25]); hold on;
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels_SMOS{yi}, 'FontSize', 20)

    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

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

    textm(text1_lat, text1_lon, 'SMOS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi ~= 1
        plabel off
    end
    mlabel off

end % yi

c = colorbar('Position', [.66 .1 .01 .81]);
c.Title.String = unit;
c.FontSize = 12;
ddd
if remove_climate == 1
    exportgraphics(gcf,'figure_SSSA_SMAP_SMOS_ROMS.png','Resolution',150) 
else
    exportgraphics(gcf,'figure_SSS_SMAP_SMOS_ROMS.png','Resolution',150) 
end