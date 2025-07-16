%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS SSS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast_common';

exp = 'Dsm4';
startdate = datenum(2018,7,1);
vari_str = 'salt';
yyyy_all = 2019:2023;
timenum_target = datenum(yyyy_all(1),1,1):datenum(yyyy_all(end),12,31);
layer = 45;

ismap = 0;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load mask_common.mat
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

% Model
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

SSS = [];
for ti = 1:length(timenum_target)
    timenum = timenum_target(ti);
    filenum = datenum(timenum) - startdate + 1;
    fstr = num2str(filenum, '%04i');

    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];

    if filenum == 1640
        file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
    elseif filenum == 1826
        file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
    end

    if exist(file)
        SSS_tmp = ncread(file,vari_str, [1 1 g.N 1], [Inf Inf 1 Inf]);
        SSS_area_tmp = sum(SSS_tmp(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
        SSS = [SSS; SSS_area_tmp];
    else
        SSS = [SSS; NaN];
    end
    disp([datestr(timenum, 'yyyymmdd'), '...'])
end % ti
dd
timenum = timenum_target;
figure; hold on; grid on
plot(timenum, SSS, '-o');
% plot(timenum, SSS_bot, '-o');
xticks(datenum(yyyy_all,1,15));
xlim([datenum(yyyy_all(1),1,1) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

output_filename = ['SSS_ROMS_', region, '_daily.mat'];

save(output_filename, 'timenum', 'SSS')