%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged hice thin to satellite using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4_mk2';
region = 'Koryak_coast_basin';
title_str = strrep(region, '_', ' ');

ismap = 0;
isCICE = 1;
isROMS = 1;

yyyy = 9999;
ystr = num2str(yyyy);

if yyyy == 9999
    xlimit = [datenum(2018,10,1)-1 datenum(2022,7,31)+1];
else
    xlimit = [datenum(yyyy-1,10,1)-1 datenum(yyyy,7,31)+1];
end

if ismap == 1
    g = grd('BSf');
    [mask, area] = mask_and_area(region, g);
    mask(isnan(mask)) = 0;
    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('NW_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_' region], '-dpng')
end

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 500])

% ROMS thin ice thickness
if strcmp(exp, 'Dsm4')
    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/hice/', region, '/hice_thin_ROMS_', region, '_daily.mat'])
else
    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/', exp, '/hice/', region, '/hice_thin_ROMS_', region, '_daily.mat'])
end
pm = plot(timenum, hice, '-k', 'LineWidth', 2);

% SMOS-SMAP combined thin ice thickness
load(['/data/jungjih/Observations/Sea_ice/SMOS_SMAP/', region, '/hi_thin_combined_', region, '_daily.mat'])
po = plot(timenum, hi, '-r', 'LineWidth', 2);

if yyyy == 9999
    xticks([datenum(2012:2024,1,1)]);
else
    xticks([datenum(yyyy-1,10:12,1), datenum(yyyy,1:7,1)]);
end
xlim(xlimit)
ylim([0 50])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylabel('cm')
set(gca, 'FontSize', 14)
box on

l = legend([po, pm], 'Observation (SMOS & SMAP)', 'Model (ROMS)');
l.Location = 'NorthWest';
l.FontSize = 20;

title(['Thin ice thickness (', strrep(region, '_', ' '), ')'], 'FontSize', 15)

if isCICE == 1
    % CICE sea ice concentration
    load(['/data/jungjih/Models/CICE/hice/', region, '/hice_thin_CICE_', region, '_daily.mat'])
    pc = plot(timenum, hice, '-g', 'LineWidth', 2);
    l = legend([po, pm, pc], 'Observation (SMOS & SMAP)', 'Model (ROMS)', 'Model (CICE)');
    uistack(pc, 'bottom')
end

if isROMS == 1
    exp2 = 'Dsm4';
    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp2, '/hice/', region, '/hice_thin_ROMS_', region, '_daily.mat'])
    pm2 = plot(timenum, hice, '-', 'Color', [.7 .7 .7], 'LineWidth', 2);
    if isCICE == 1
        l = legend([po, pm, pm2, pc], 'Observation (SMOS & SMAP)', ['Model (ROMS ', replace(exp, '_', ' '), ')'], 'Model (ROMS control)', 'Model (CICE)');
    else
        l = legend([po, pm, pm2], 'Observation (SMOS & SMAP)', ['Model (ROMS ', replace(exp, '_', ' '), ')'], 'Model (ROMS control)');
    end
    uistack(pm2, 'bottom')
    l.FontSize = 15;
end
l.Location = 'SouthOutside';
l.NumColumns = 4;

print(['cmp_area_avg_hice_thin_', region, '_daily_', ystr], '-dpng')