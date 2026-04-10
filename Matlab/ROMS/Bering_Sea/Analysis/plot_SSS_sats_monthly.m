%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sats SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';
[lon, lat] = load_domain(map);

vari_str = 'salt';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

remove_climate = 1;

% Load grid information
g = grd('BSf');

% Figure properties
if remove_climate == 1
climit = [-2 2];
interval = 0.5;
[color, contour_interval] = get_color('redblue', climit, interval);
savename = 'SSSA';
else
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color('jet', climit, interval);
savename = 'SSS';
end
unit = 'psu';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 12;

figure;
set(gcf, 'Position', [1 200 850 900])
t = tiledlayout(5,4);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % SMAP SSS
    version = 6;
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMAP', version, yyyy, mm);
    if remove_climate == 1
        [lat_tmp, lon_tmp, vari_sat_climate] = load_SSS_sat_2d_climate('SMAP', version, mm);
        vari_sat = vari_sat - vari_sat_climate;
    end
    index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
    index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);
    vari_sat_part = vari_sat(index_lon,index_lat);
    [lat_sat2, lon_sat2] = meshgrid(lat_sat(index_lat), lon_sat(index_lon));
    
    % SMAP plot
    nexttile(yi); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    T = plot_contourf([], lat_sat2,lon_sat2,vari_sat_part,color,climit,contour_interval);

    textm(text1_lat-.3, text1_lon, {'SMAP', 'RSS'}, 'FontSize', text_FS)
%     textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
    plabel('FontSize', 10);
    if yi ~= 1
        plabel off
    end
    mlabel off
    title(title_str, 'FontSize', text_FS)

    % SMOS BEC Arctic
    version = 4;
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMOS_BEC', version, yyyy, mm);
    if remove_climate == 1
        [lat_tmp, lon_tmp, vari_sat_climate] = load_SSS_sat_2d_climate('SMOS_BEC', version, mm);
        vari_sat = vari_sat - vari_sat_climate;
    end
    F = scatteredInterpolant(lat_sat(:), lon_sat(:), vari_sat(:));
    lat_sat_regular = [min(min(lat))-1:0.25:max(max(lat))+1]';
    lon_sat_regular = [min(min(lon))-1:0.25:max(max(lon))+1]';
    [lat_sat2, lon_sat2] = meshgrid(lat_sat_regular, lon_sat_regular);
    vari_sat_part = F(lat_sat2, lon_sat2);

    % SMOS BEC plot
    nexttile(yi+4); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    T = plot_contourf([], lat_sat2,lon_sat2,vari_sat_part,color,climit,contour_interval);

    textm(text1_lat-.3, text1_lon, {'SMOS', 'BEC'}, 'FontSize', text_FS)
    textm(text2_lat, text2_lon, 'Arctic', 'FontSize', text_FS)
    plabel('FontSize', 10);
    if yi ~= 1
        plabel off
    end
    mlabel off

    % SMOS SSS
    version = 10;
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMOS', version, yyyy, mm);
    if remove_climate == 1
        [lat_tmp, lon_tmp, vari_sat_climate] = load_SSS_sat_2d_climate('SMOS', version, mm);
        vari_sat = vari_sat - vari_sat_climate;
    end
    index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
    index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);
    vari_sat_part = vari_sat(index_lon,index_lat);
    [lat_sat2, lon_sat2] = meshgrid(lat_sat(index_lat), lon_sat(index_lon));

    % SMOS plot
    nexttile(yi+8); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    T = plot_contourf([], lat_sat2,lon_sat2,vari_sat_part,color,climit,contour_interval);

    textm(text1_lat-.3, text1_lon, {'SMOS', 'CEC'}, 'FontSize', text_FS)
%     textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
    plabel('FontSize', 10);
    if yi ~= 1
        plabel off
    end
    mlabel off

    % SMOS CEC Arctic SSS
    version = 2;
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMOS_Arctic', version, yyyy, mm);
    if remove_climate == 1
        [lat_tmp, lon_tmp, vari_sat_climate] = load_SSS_sat_2d_climate('SMOS_Arctic', version, mm);
        vari_sat = vari_sat - vari_sat_climate;
    end
    F = scatteredInterpolant(lat_sat(:), lon_sat(:), vari_sat(:));
    lat_sat_regular = [min(min(lat))-1:0.25:max(max(lat))+1]';
    lon_sat_regular = [min(min(lon))-1:0.25:max(max(lon))+1]';
    [lat_sat2, lon_sat2] = meshgrid(lat_sat_regular, lon_sat_regular);
    vari_sat_part = F(lat_sat2, lon_sat2);

    % SMOS CEC Arctic plot
    nexttile(yi+12); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    T = plot_contourf([], lat_sat2,lon_sat2,vari_sat_part,color,climit,contour_interval);

    textm(text1_lat-.3, text1_lon, {'SMOS', 'CEC'}, 'FontSize', text_FS)
    textm(text2_lat, text2_lon, 'Arctic', 'FontSize', text_FS)
    plabel('FontSize', 10);
    if yi ~= 1
        plabel off
    end
    mlabel off

    % CMEMS
    version = 0;
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('CMEMS', version, yyyy, mm);
    if remove_climate == 1
        [lat_tmp, lon_tmp, vari_sat_climate] = load_SSS_sat_2d_climate('CMEMS', version, mm);
        vari_sat = vari_sat - vari_sat_climate;
    end
    index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
    index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);
    vari_sat_part = vari_sat(index_lon,index_lat);
    [lat_sat2, lon_sat2] = meshgrid(lat_sat(index_lat), lon_sat(index_lon));

    % CMEMS plot
    nexttile(yi+16); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    T = plot_contourf([], lat_sat2,lon_sat2,vari_sat_part,color,climit,contour_interval);

    textm(text1_lat, text1_lon, 'CMEMS', 'FontSize', text_FS-1)
%     textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    plabel('FontSize', 10);
    if yi ~= 1
        plabel off
    end
end % yi

c = colorbar;
c.Layout.Tile = 'east';
c.Title.String = unit;
c.FontSize = 15;

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_sats_', mstr, '_monthly'],'-dpng');
exportgraphics(gcf,[savename, '_sats_', mstr, '_monthly.tif'],'Resolution',300)