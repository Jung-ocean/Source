clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2019:2022;
mm = 5;
mstr = num2str(mm, '%02i');

labels_ASI = {'a', 'b', 'c', 'd'};
labels_ROMS = {'e', 'f', 'g', 'h'};

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
filepath_sat = ['/data/jungjih/Observations/Sea_ice/ASI/monthly_ROMSgrid/'];

% Figure properties
interval = 0.1;
climit = [0 1];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = gray(num_color);
unit = '';
savename = 'cmp_aice';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 66;
text2_lon = -178;
text_FS = 15;

figure;
set(gcf, 'Position', [1 200 1500 600])
% Figure title
title(['Sea ice concentration in ', datestr(datenum(0,mm,15), 'mmm')], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % Satellite plot
    filename_sat = ['asi-AMSR2-n6250-', ystr, mstr, '-v5.4.nc'];
    file_sat = [filepath_sat, filename_sat];
    vari_sat = ncread(file_sat, 'z')'/100;
    
    subplot('Position',[.05 + 0.20*(yi-1),.55,.20,.4])
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels_ASI{yi}, 'FontSize', 20)

    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

%     T = pcolorm(g.lat_rho,g.lon_rho,vari_sat); shading flat
        % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari_sat(vari_sat < climit(1)) = climit(1);
    vari_sat(vari_sat > climit(2)) = climit(2);
    [cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
%     vari_bar(isnan(vari_bar) == 1) = 0;
%     contourm(g.lat_rho, g.lon_rho, vari_bar, contour_interval, 'k');

    textm(text1_lat, text1_lon, 'ASI', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off
    
    % ROMS plot
    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'aice')'; 

    subplot('Position',[.05 + 0.20*(yi-1),.1,.20,.4])
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels_ROMS{yi}, 'FontSize', 20)

    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

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
%     vari_surf(isnan(vari_surf) == 1) = 0;
%     contourm(g.lat_rho, g.lon_rho, vari_surf, contour_interval, 'k');

    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel('FontSize', 10);

end % yi

c = colorbar('Position', [.85 .1 .01 .85]);
c.Title.String = unit;

exportgraphics(gcf,'figure_cmp_aice_map.png','Resolution',150) 