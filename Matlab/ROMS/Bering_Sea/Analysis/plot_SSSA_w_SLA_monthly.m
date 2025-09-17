%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSSA and zeta anoamly monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

exp = 'Dsm4';
vari_str = 'salt';
yyyy_all = 2019:2023;
mm = 6;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Figure properties
colormap2 = 'redblue';
climit2 = [-1 1];
interval2 = 0.2;
[color2, contour_interval2] = get_color(colormap2, climit2, interval2);

unit = 'psu';
savename = 'SSSA_and_zetaA';

figure;
set(gcf, 'Position', [1 200 1800 500])
t = tiledlayout(1,5);
% Figure title
title(t, {['SSSA and zeta anomaly in ', datestr(datenum(0,mm,15), 'mmm')], ''}, 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    SSS = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]);
    SSS_all(yi,:,:) = SSS;
    zeta = ncread(file, 'zeta');
    zeta_all(yi,:,:) = zeta;     
end

SSS_climate = squeeze(mean(SSS_all,1));
zeta_climate = squeeze(mean(zeta_all,1));

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'yyyy');

    vari_SSS = squeeze(SSS_all(yi,:,:)) - SSS_climate;

    % SSSA plot
    ax2 = nexttile(yi); hold on;
    plot_map(map, 'mercator', 'l')
%     contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    h = plot_contourf(ax2, g.lat_rho, g.lon_rho, vari_SSS, color2, climit2, contour_interval2);
    title([(title_str)])

    if yi == 5
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval2;
    end
  
    vari_SLA = squeeze(zeta_all(yi,:,:)) - zeta_climate;
    vari_SLA(isnan(vari_SLA)) = -1000;
    contourm(g.lat_rho, g.lon_rho, vari_SLA, [-3:0.025:3], 'k', 'LineWidth', 1.5);
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');