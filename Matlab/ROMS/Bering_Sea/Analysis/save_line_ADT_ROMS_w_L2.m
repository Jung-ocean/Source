%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save ROMS zeta and along-track ADT from Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';
exp = 'Dsm4';

% Line numbers
direction = 'a';
if strcmp(direction, 'p')
    lines = 1:15; % pline
else
    lines = 1:24; % aline
end

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/'];

year_start = 2018;
month_start = 7;

% Load grid information
g = grd('BSf');

% Satellite
filepath_sat = ['/data/jungjih/Observations/Satellite_SSH/Merged/Merged_MMv5.2_podaac/'];

index = 1;
for li = 1:length(lines)
    line = lines(li); lstr = num2str(line, '%02i');
    ADTfile = load([filepath_sat, 'ADT_', direction, 'line_', lstr, '.mat']);
    ADT_all = ADTfile.ADT_all;
    lat_line = ADTfile.lat_line;
    lon_line = ADTfile.lon_line;
    timenum = ADTfile.timenum_all;
    timevec = datevec(timenum);

    h_line = interp2(g.lon_rho', g.lat_rho', g.h', lon_line, lat_line);

    for ti = 1:size(timevec,1)

        timenum_tmp = floor(datenum(timevec(ti,:)));

        filenumber = timenum_tmp - datenum(year_start,month_start,1) + 1;
        fstr = num2str(filenumber, '%04i');
        file = [filepath_control, exp, '_avg_', fstr, '.nc'];
        if filenumber == 0119
            file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
        elseif filenumber == 1640
            file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
        elseif filenumber == 1826
            file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
        end

        if exist(file) == 2
            zeta = ncread(file,'zeta');
            SSS = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]);
            if ~isempty(zeta) 
                zeta_line = interp2(g.lon_rho', g.lat_rho', zeta', lon_line, lat_line);
                ADT.model{index} = zeta_line';
            else
                ADT.model{index} = NaN;
            end
        else
            ADT.model{index} = NaN;
        end

        ADT.time{index} = timenum_tmp(1);
        ADT.line{index} = li;
        ADT.obs{index} = ADT_all(ti,:);

        index = index+1;
    end
    ADT.lon{li} = lon_line;
    ADT.lat{li} = lat_line;
    ADT.depth{li} = h_line;

    disp([num2str(li), '/', num2str(lines(end))])
end

save(['ADT_model_obs_', direction, 'line.mat'], 'ADT')