%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged sat SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

sat = 'SMOS_BEC';
region = 'Cape_Olyutor';
area_frac_cutoff = 0.99;
% area_frac_cutoff = 0.1;

ismap = 0;

% maskname = ['common_07_01'];

mm_all = 1:12;
mstr = num2str(mm_all, '%02i');

switch sat
    case 'SMAP'
        yyyy_all = 2015:2025;
        version = 6;
    case 'SMOS'
%         yyyy_all = 2010:2023;
%         version = 9;
        yyyy_all = 2010:2024;
        version = 10;
    case 'CMEMS'
        yyyy_all = 2019:2022;
        version = 0;
    case 'SMOS_BEC'
        yyyy_all = 2011:2022;
        version = 4;
    case 'SMOS_Arctic'
        yyyy_all = 2010:2023;
        version = 2;
    case 'OISSS'
        yyyy_all = 2011:2024;
        version = 2;
end

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load(['mask_' , maskname, '.mat'])
%     load(['mask_common_06_15.mat'])
    dx = 1./g.pm; dy = 1./g.pn;
    mask = mask_common./mask_common;
    area = dx.*dy.*mask;
else
    [mask, area] = mask_and_area(region, g);
end

if ismap == 1
    % Area plot
    mask_map = mask;
    mask_map(isnan(mask_map) == 1) = 0;

    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('NW_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_' region], '-dpng')
end

SSS = [];
err = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

%         if strcmp(sat, 'SMOS') & yyyy == 2024
%             version = 10;
%         end
        [SSS_tmp, err_tmp] = load_area_avg_SSS_sat_monthly(sat, version, yyyy, mm, g, mask, area, area_frac_cutoff);
        SSS = [SSS; SSS_tmp];
        err = [err; err_tmp];

        disp([ystr, mstr])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS, '-o');
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

if length(mm_all) == 1
    output_filename = ['SSS_', sat, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['SSS_', sat, '_', region, '.mat'];
end

save(output_filename, 'timenum', 'SSS', 'err', 'area_frac_cutoff')