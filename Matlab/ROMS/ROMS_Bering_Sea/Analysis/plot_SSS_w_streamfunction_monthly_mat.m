%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSS with streamfunction monthly using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'stream';
yyyy_all = 2019:2022;
mm = 4;
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
filepath_streamfunction = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/transport/streamfunction/'];

% Load grid information
g = grd('BSf');

% Figure properties
switch map
    case 'Gulf_of_Anadyr'
        contour_interval = -10:.1:10;
    case 'Eastern_Bering'
        contour_interval = -10:.1:10;
end

climit = [29 34];
interval = 0.25;
contourf_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';
savename = 'SSS_w_streamfunction';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
    case 'Eastern_Bering'
        text1_lat = 65.7;
        text1_lon = -184.8;
        text2_lat = 65.7;
        text2_lon = -166;
        text_FS = 15;
end

figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);
% Figure title
title(t, ['SSS with streamfunction (interval = 0.1 Sv)'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = squeeze(ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]))';

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

%     p = pcolorm(g.lat_rho, g.lon_rho, vari.*g.mask_rho./g.mask_rho); shading flat

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    [cs, h] = contourf(x, y, vari, contourf_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(h, 'bottom')
    plot_map(map, 'mercator', 'l')
    
    if yi == 4
        c = colorbar;
        c.Title.String = unit;
    end

    filename = ['psi_', ystr, mstr, '.mat'];
    load([filepath_streamfunction, filename])
    psi_rho = psi_rho/1e6;
    % contourm(g.lat_rho, g.lon_rho, psi_rho./g.mask_rho, contour_interval, 'k')
    
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    contour(x,y,psi_rho.*g.mask_rho, contour_interval, 'k', 'LineWidth', 1)

    if strcmp(map, 'Gulf_of_Anadyr')
        textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
        textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
    else
        title(['ROMS (', title_str, ')'])
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', mstr, '_monthly'],'-dpng');