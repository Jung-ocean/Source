%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged SMOS SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

region = 'Koryak_coast';
area_frac_cutoff = 0.99;
% area_frac_cutoff = 0.1;

yyyy_all = 2010:2024;
mm_all = 1:12;

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load mask_common.mat
    dx = 1./g.pm; dy = 1./g.pn;
    mask = mask_common./mask_common;
    area = dx.*dy.*mask;
else
    [mask, area] = mask_and_area(region, g);
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

        [SSS_tmp, err_tmp] = load_area_avg_SSS_sat_monthly('SMOS', yyyy, mm, g, mask, area, area_frac_cutoff);
        SSS = [SSS; SSS_tmp];
        err = [err; SSS_tmp];

        disp([ystr, mstr])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS, '-o');
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

if length(mm_all) == 1
    output_filename = ['SSS_SMOS_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['SSS_SMOS_', region, '.mat'];
end
save(output_filename, 'timenum', 'SSS', 'err', 'area_frac_cutoff')