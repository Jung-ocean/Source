clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2021:2021;
mm = 7;
mstr = num2str(mm, '%02i');

isice = 0;

climit = [29 34];
interval = 0.25;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';

savename = 'SSS_climate';

% Load grid information
g = grd('BSf');
lat = g.lat_rho;
lon = g.lon_rho;

figure;
set(gcf, 'Position', [1 200 1800 700])
% Figure title

t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % Satellite SSS
    % RSS SMAP v6.0
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_climate('SMAP', 6, mm);

    latind = find(40 < lat_sat & lat_sat <80);
    lonind = find(-250 < lon_sat & lon_sat < -100);
    lat_sat = lat_sat(latind);
    lon_sat = lon_sat(lonind);
    vari_sat = vari_sat(lonind,latind);
    [lat2, lon2] = meshgrid(lat_sat, lon_sat);

    % Tile
    nexttile(yi)

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

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
        textm(65, -205, 'SMAP', 'FontSize', 60)
    end
    
    title('July mean SSS (2015-2023)', 'FontSize', 35);

    plabel('FontSize', 12)
    mlabel('FontSize', 12)
    
end

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % Satellite SSS
    % BEC SMOS Arctic v4.0
    [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_climate('SMOS_BEC', 4, mm);

    F = scatteredInterpolant(lat_sat(:), lon_sat(:), vari_sat(:));
    lat_sat_regular = [min(min(lat))-1:0.25:max(max(lat))+1]';
    lon_sat_regular = [min(min(lon))-1:0.25:max(max(lon))+1]';
    [lat2, lon2] = meshgrid(lat_sat_regular, lon_sat_regular);
    vari_sat = F(lat2, lon2);

    % Tile
    nexttile(yi+1);

    plot_map(map, 'mercator', 'l')
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

    if yi == 1
        textm(65, -205, 'SMOS', 'FontSize', 60)
    end

    title('July mean SSS (2015-2022)', 'FontSize', 35);

    plabel('FontSize', 12)
    mlabel('FontSize', 12)
    plabel off
    
end % yi

c = colorbar;
c.Layout.Tile = 'east';
c.Title.String = unit;
c.FontSize = 20;
asdf
exportgraphics(gcf,[savename, '_SMAP_SMOS.png'],'Resolution',150)