%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS suvstr with zeta monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Eastern_Bering';

exp = 'Dsm4';
vari_str = 'suvstr';
yyyy_all = 2019:2023;
mm = 5;
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Load grid information
g = grd('BSf');

% Figure properties
skip = 1;
npts = [0 0 0 0];

climit = [-30 10];
interval = 2.5;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'cm';
savename = 'suvstr_w_zeta';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
    
        interval_model = 40;
        scale_model = 15;

        scale = 0.1;
        scale_lat = 64;
        scale_lon = -184.5;
        scale_text = '0.1 N/m^2';
        scale_text_lat = 63.5;
        scale_text_lon = -184.5;

    case 'Eastern_Bering'
        text1_lat = 65.7;
        text1_lon = -184.8;
        text2_lat = 65.7;
        text2_lon = -166;
        text_FS = 15;

        interval_model = 50;
        scale_model = 10;

        scale = 0.2;
        scale_lat = 62.5;
        scale_lon = -162.5;
        scale_text = '0.2 N/m^2';
        scale_text_lat = 62;
        scale_text_lon = -162.5;
end

figure;
set(gcf, 'Position', [1 200 1800 600])
t = tiledlayout(1,5);
% Figure title
title(t, ['Surface stress with zeta (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    zeta = 100*ncread(file, 'zeta'); % m -> cm
    sustr = ncread(file, 'sustr');
    svstr = ncread(file, 'svstr');
    
    [sustr_rho,svstr_rho,lonred,latred,maskred] = uv_vec2rho_J(sustr,svstr,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    %     p = pcolorm(g.lat_rho, g.lon_rho, zeta.*g.mask_rho./g.mask_rho); shading flat
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    zeta(zeta < climit(1)) = climit(1);
    [cs, h] = contourf(x, y, zeta, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(h, 'bottom')
    plot_map(map, 'mercator', 'l')

    %     colormap jet
%     uistack(p, 'bottom')
%     plot_map(map, 'mercator', 'l')
%     caxis(climit)
%     
%     zeta_contour = zeta;
%     zeta_contour(isnan(zeta_contour) == 1) = -1000;
%     [cs, h] = contourm(g.lat_rho, g.lon_rho, zeta_contour, contour_interval, 'k');
    
    if yi == 4
        c = colorbar;
        c.Title.String = unit;
    end

    q = quiverm(g.lat_rho(1:interval_model:end, 1:interval_model:end), ...
                g.lon_rho(1:interval_model:end, 1:interval_model:end), ...
                svstr_rho(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                sustr_rho(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

    q(1).Color = 'k';
    q(2).Color = 'k';
%     q(1).Color = [0 1 1];
%     q(2).Color = [0 1 1];
    q(1).LineWidth = 2;
    q(2).LineWidth = 2;

    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    qscale = quiverm(scale_lat, scale_lon, 0.*scale_model, scale.*scale_model, 0);
    qscale(1).Color = 'r';
    qscale(2).Color = 'r';
    tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', 10);
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', mstr, '_monthly'],'-dpng');