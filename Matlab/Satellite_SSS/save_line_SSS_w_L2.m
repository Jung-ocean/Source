%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save satellite SSS along the ADT track from Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

sat = 'SMOS';

% Line numbers
direction = 'p';
if strcmp(direction, 'p')
    lines = 1:15; % pline
else
    lines = 1:24; % aline
end

% Satellite
filepath_sat = ['/data/jungjih/Observations/Satellite_SSH/Merged/Merged_MMv5.2_podaac/ADT_line_no_filter/'];

index = 1;
for li = 1:length(lines)
    line = lines(li); lstr = num2str(line, '%02i');
    ADTfile = load([filepath_sat, 'ADT_', direction, 'line_', lstr, '.mat']);
    ADT_all = ADTfile.ADT_all;
    lat_line = ADTfile.lat_line;
    lon_line = ADTfile.lon_line;
    timenum = ADTfile.timenum_all;
    timevec = datevec(timenum);

    timenum_target = min(floor(timenum)):max(floor(timenum));
    for ti = 1:length(timenum_target)

        timenum_tmp = timenum_target(ti);

        try
            [timenum_all, vari_all] = load_SSS_sat_1d(sat, timenum_tmp, timenum_tmp, lat_line, lon_line);
        catch
            vari_all = NaN;
        end

        if length(vari_all) > 1
            SSS.sat{index} = vari_all';
        else
            SSS.sat{index} = NaN;
        end

        SSS.time{index} = timenum_tmp(1);
        SSS.line{index} = li;

        index = index+1;
    end
    SSS.lon{li} = lon_line;
    SSS.lat{li} = lat_line;

    disp([num2str(li), '/', num2str(lines(end))])
end

save(['SSS_', sat, '_', direction, 'line.mat'], 'SSS')