%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save ROMS zeta and along-track ADT from Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';
lines = 1:13;

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/'];

year_start = 2018;
month_start = 7;

% Load grid information
g = grd('BSf');

% Satellite
filepath_sat = ['/data/jungjih/Observations/Satellite_SSH/Merged_MMv5.1_podaac/ADT_line_no_filter/'];

index = 1;
for li = 1:length(lines)
    line = lines(li); lstr = num2str(line);
    ADTfile = load([filepath_sat, 'ADT_line_', lstr, '.mat']);
    ADT_all = ADTfile.ADT_all;
    lat_line = ADTfile.lat_line;
    lon_line = ADTfile.lon_line;
    timenum = ADTfile.timenum_all;

    timevec = datevec(timenum);

    for ti = 1:size(timevec,1)

        timenum_tmp = floor(datenum(timevec(ti,:)));

        filenumber = timenum_tmp - datenum(year_start,month_start,1) + 1;
        fstr = num2str(filenumber, '%04i');

        file = [filepath_control, 'Dsm2_spng_avg_', fstr, '.nc'];

        if exist(file) == 2
            zeta = ncread(file,'zeta')';
            zeta_line = interp2(g.lon_rho, g.lat_rho, zeta, lon_line, lat_line);

            ADT.model{index} = zeta_line';
            ADT.time{index} = timenum_tmp;
        else
            ADT.model{index} = NaN;
            ADT.time{index} = NaN;
        end

        ADT.line{index} = li;
        ADT.obs{index} = ADT_all(ti,:);

        index = index+1;
    end
    ADT.lon{li} = lon_line;
    ADT.lat{li} = lat_line;

    disp([num2str(li), '/', num2str(lines(end))])
end

save ADT_model_obs.mat ADT