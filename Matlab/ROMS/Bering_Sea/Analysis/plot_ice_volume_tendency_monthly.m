%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS ice volume tendency
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');
startdate = datenum(2018,7,1);

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy=dx.*dy;

% Figure properties
interval = .2;
climit = [-1 1];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color_tmp = redblue; close all
c1 = interp1(color_tmp(:,1), linspace(1,length(color_tmp),num_color));
c2 = interp1(color_tmp(:,2), linspace(1,length(color_tmp),num_color));
c3 = interp1(color_tmp(:,3), linspace(1,length(color_tmp),num_color));
color = [c1; c2; c3]';
unit = 'm^3/s';

savename = 'ice_volume_tendency';

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
title(t, ['Sea ice volume tendency (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filenum_start = datenum(yyyy,mm,1) - startdate + 1;
    fstr_start = num2str(filenum_start, '%04i');
    filename_start = [exp, '_his_', fstr_start, '.nc'];
    file_start = [filepath, filename_start];
    hice_start = ncread(file_start, 'hice')';

    filenum_end = datenum(yyyy,mm,eomday(yyyy,mm)) - startdate + 1;
    fstr_end = num2str(filenum_end, '%04i');
    filename_end = [exp, '_his_', fstr_end, '.nc'];
    file_end = [filepath, filename_end];
    hice_end = ncread(file_end, 'hice')';

    num_day = eomday(yyyy,mm) - 1 + 1;
    tendency = (hice_end - hice_start)./(60*60*24*num_day);

    vari = dxdy.*tendency;
    save(['tendency_', ystr, mstr, '.mat'], 'vari')

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    p = plot_contourf(g.lat_rho, g.lon_rho, vari, contour_interval, climit, color);
    plot_map(map, 'mercator', 'l')
    if yi == 4
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval;
    end

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