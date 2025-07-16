%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSS and SSSA monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

exp = 'Dsm4';
vari_str = 'salt';
yyyy_all = 2019:2023;
mm = 1;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Figure properties
colormap1 = 'jet';
climit1 = [29 34];
interval1 = 0.25;
[color1, contour_interval1] = get_color(colormap1, climit1, interval1);

colormap2 = 'redblue';
climit2 = [-1 1];
interval2 = 0.2;
[color2, contour_interval2] = get_color(colormap2, climit2, interval2);

unit = 'psu';
savename = 'SSS_and_SSSA';

figure;
set(gcf, 'Position', [1 200 1800 600])
t = tiledlayout(2,5);
% Figure title
title(t, {['SSS and SSSA in ', datestr(datenum(0,mm,15), 'mmm')], ''}, 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]);
    vari_all(yi,:,:) = vari;

    % SSS plot
    ax1 = nexttile(yi); hold on;
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    h = plot_contourf(ax1, g.lat_rho, g.lon_rho, vari, color1, climit1, contour_interval1);
    title(['SSS (', title_str, ')'])
    mlabel off

    if yi == 5
        c = colorbar;
        c.Title.String = unit;
    end
end

vari_climate = squeeze(mean(vari_all,1));

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    vari = squeeze(vari_all(yi,:,:)) - vari_climate;

    % SSSA plot
    ax2 = nexttile(yi+length(yyyy_all)); hold on;
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    h = plot_contourf(ax2, g.lat_rho, g.lon_rho, vari, color2, climit2, contour_interval2);
    title(['SSSA (', title_str, ')'])

    if yi == 5
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval2;
    end
  
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');