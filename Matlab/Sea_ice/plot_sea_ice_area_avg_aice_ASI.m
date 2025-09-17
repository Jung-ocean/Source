%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ASI sea ice concentration using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
region = 'Koryak_coast';
title_str = strrep(region, '_', ' ');

xlimit = [datenum(2018,10,1)-1 datenum(2023,7,31)+1];

ismap = 1;

if ismap == 1
    g = grd('BSf');
    [mask, area] = mask_and_area(region, g);
    mask(isnan(mask)) = 0;
    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('NW_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['area_' region], '-dpng')
end

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 500])

% ASI sea ice concentration
load(['/data/jungjih/Observations/Sea_ice/ASI/figures/', region, '/Fi_ASI_', region, '_daily.mat'])
po = plot(timenum, Fi, '-r', 'LineWidth', 2);
asdfasdf
xticks([datenum(2012:2024,1,1)]);
xlim(xlimit)
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
set(gca, 'FontSize', 15)
box on

l = legend([po, pm], 'Observation (ASI)', 'Model (ROMS)');
l.Location = 'NorthWest';
l.FontSize = 20;
adfasdf
print(['cmp_area_avg_aice_', region, '_daily'], '-dpng')
