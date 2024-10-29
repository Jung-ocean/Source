%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS hice (thin ice thickness) to Satellite monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'hice';
yyyy_all = 2019:2022;
mm = 6;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Figure properties
interval = 10;
climit = [0 50];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'cm';
savename = 'cmp_hice';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

figure;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(2,4);
% Figure title
title(t, ['Thin ice thickness in ', datestr(datenum(0,mm,15), 'mmm')], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'hice')'*100;
    
    % ROMS plot
    nexttile(yi); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    %     T = pcolorm(g.lat_rho,g.lon_rho,vari_surf); shading flat
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < 0) = 0;
    vari(vari > 50) = 50;
    [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
%     vari_surf(isnan(vari_surf) == 1) = 0;
%     contourm(g.lat_rho, g.lon_rho, vari_surf, contour_interval, 'k');

    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi == 4
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.Ticks = contour_interval;
    end

    file_sat = ['hice_thin_', ystr, mstr, '.mat'];
    data_sat = load(file_sat);
    lon = data_sat.lon';
    lat = data_sat.lat';
    vari_sat = data_sat.hice_thin';

    % Satellite plot
    nexttile(yi+4); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

%     T = pcolorm(g.lat_rho,g.lon_rho,vari_bar); shading flat
        % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(lat, lon);  % Convert lat/lon to projected x, y coordinates
    vari_sat(vari_sat < 0) = 0;
    vari_sat(vari_sat > 50) = 50;
    [cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
%     vari_bar(isnan(vari_bar) == 1) = 0;
%     contourm(g.lat_rho, g.lon_rho, vari_bar, contour_interval, 'k');

    textm(text1_lat, text1_lon, 'Sat', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

%     if yi == 4
%         c = colorbar;
%         c.Title.String = unit;
%     end
  
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_to_sat_', mstr, '_monthly'],'-dpng');
