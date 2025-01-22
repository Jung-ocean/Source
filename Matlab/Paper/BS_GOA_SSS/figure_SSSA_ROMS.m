clear; clc; close all

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

% Figure properties
interval = 0.25;
climit = [29 34];
contour_interval_SSS = climit(1):interval:climit(2);
contour_interval_Sbar = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';
savename = 'SSS_and_Sbar';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

figure;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(2,4);
% Figure title
title(t, ['SSS and Sbar in ', datestr(datenum(0,mm,15), 'mmm')], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt'); 
    vari = permute(vari, [3 2 1]);
    zeta = ncread(file, 'zeta')';
    
    vari_surf = squeeze(vari(g.N,:,:));

    z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
    dz = z_w(2:end,:,:) - z_w(1:end-1,:,:);
    vari_bar = squeeze(sum(vari.*dz,1)./sum(dz,1));

    if remove_climate == 1
        filepath_climate = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/climate/'];
        filename_climate = [exp, '_climate_', mstr, '.nc'];
        file_climate = [filepath_climate, filename_climate];
        vari_climate = ncread(file_climate, 'salt'); 
        vari_climate = permute(vari_climate, [3 2 1]);
        zeta_climate = ncread(file_climate, 'zeta')';

        vari_surf_climate = squeeze(vari_climate(g.N,:,:));

        z_w = zlevs(g.h,zeta_climate,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
        dz = z_w(2:end,:,:) - z_w(1:end-1,:,:);
        vari_bar_climate = squeeze(sum(vari_climate.*dz,1)./sum(dz,1));

        vari_surf = vari_surf - vari_surf_climate;
        vari_bar = vari_bar - vari_bar_climate;

        climit_SSS = [-2 2];
        interval = 0.5;
        contour_interval_SSS = climit_SSS(1):interval:climit_SSS(2);
        num_color = diff(climit_SSS)/interval;
        color_tmp = redblue;
        color_SSS = color_tmp(linspace(1,length(color_tmp),num_color),:);

        climit_Sbar = [-1 1];
        interval = 0.25;
        contour_interval_Sbar = climit_Sbar(1):interval:climit_Sbar(2);
        num_color = diff(climit_Sbar)/interval;
        color_tmp = redblue;
        color_Sbar = color_tmp(linspace(1,length(color_tmp),num_color),:);
    end

    % Surface plot
    subplot('Position',[.05 + 0.20*(yi-1),.55,.20,.4]); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari_surf(vari_surf < climit_SSS(1)) = climit_SSS(1);
    vari_surf(vari_surf > climit_SSS(2)) = climit_SSS(2);
    [cs, T] = contourf(x, y, vari_surf, contour_interval_SSS, 'LineColor', 'none');
    caxis(climit_SSS)
    colormap(color_SSS)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
%     vari_surf(isnan(vari_surf) == 1) = 0;
%     contourm(g.lat_rho, g.lon_rho, vari_surf, contour_interval, 'k');

    textm(text1_lat, text1_lon, 'Surface', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off

    if yi == 4
        c = colorbar('Position', [.85 .55 .01 .4]);
        c.Title.String = unit;
    end

    % Sbar plot
    subplot('Position',[.05 + 0.20*(yi-1),.1,.20,.4]); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

%     T = pcolorm(g.lat_rho,g.lon_rho,vari_bar); shading flat
        % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari_bar(vari_bar < climit_Sbar(1)) = climit_Sbar(1);
    vari_bar(vari_bar > climit_Sbar(2)) = climit_Sbar(2);
    [cs, T] = contourf(x, y, vari_bar, contour_interval_Sbar, 'LineColor', 'none');
    caxis(climit_Sbar)
    colormap(color_Sbar)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')

    textm(text1_lat, text1_lon, 'Depth-avg', 'FontSize', 12)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
  
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel('FontSize', 10);

    if yi == 4
        c = colorbar('Position', [.85 .1 .01 .4]);
        c.Title.String = unit;
    end

end % yi

exportgraphics(gcf,'figure_SSSA_ROMS.png','Resolution',150) 