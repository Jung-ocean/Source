%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged sat SSS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

sat = 'SMOS_BEC';

region = 'Gulf_of_Anadyr_common';
area_frac_cutoff = 0.99;
% area_frac_cutoff = 0.1;

maskname = ['common_07_01'];

yyyy_all = 2019:2022;
mm_all = 6:7;

ismap = 0;

switch sat
    case 'SMAP'
        version = 6;
    case 'SMOS'
        version = 9;
    case 'CMEMS'
        version = 0;
    case 'SMOS_BEC'
        version = 4;
end

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load(['mask_', maskname, '.mat'])
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
    plot_map('Gulf_of_Anadyr', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_', maskname], '-dpng')
end

SSS = [];
err = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        for di = 1:eomday(yyyy,mm)
            dd = di;
            timenum_tmp = datenum(yyyy,mm,dd);
            timenum = [timenum; timenum_tmp];

            [SSS_tmp, err_tmp] = load_area_avg_SSS_sat_daily(sat, version, timenum_tmp, g, mask, area, area_frac_cutoff);
            SSS = [SSS; SSS_tmp];
            err = [err; SSS_tmp];

            disp(datestr(timenum_tmp, 'yyyymmdd'))
        end
    end % mi
end

figure; hold on; grid on
plot(timenum, SSS, '.-');
xticks(datenum(2010:2025,1,1));
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

output_filename = ['SSS_', sat, '_', region, '_daily.mat'];
save(output_filename, 'timenum', 'SSS', 'err', 'area_frac_cutoff')