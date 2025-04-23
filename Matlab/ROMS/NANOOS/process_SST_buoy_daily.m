%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Process buoy data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2023:2024;
filepath = '/data/jungjih/Observations/NDBC/';

stations = {
    'Port Orford'
    'Umpqua Offshore'
    'Yaquina Channel'
    'OOI Newport Shelf'
    'Stonewall Bank'
    'Tillamook Bay'
    'Clatsop Spit'
    'Columbia River Bar'
    'Astoria Canyon'
    'Grays Harbor'
    'OOI Westport Shelf'
    'OOI Westport Offshore'
    'Cape Elizabeth'
    'Eel River'
    'Humboldt Bay'
    'St Georges'
    'Neah Bay'
    };

ids = [
    46015
    46229
    46283
    46097
    46050
    46278
    46243
    46029
    46248
    46211
    46099
    46100
    46041
    46022
    46244
    46027
    46087
    ];

lats = [
    42.754
    43.772
    44.567
    44.639
    44.669
    45.561
    46.214
    46.163
    46.133
    46.857
    46.988
    46.851
    47.352
    40.716
    40.896
    41.840
    48.493
    ];

lons = -[
    124.839
    124.549
    124.237
    124.304
    124.546
    123.991
    124.126
    124.487
    124.64
    124.243
    124.567
    124.964
    124.739
    124.540
    124.358
    124.382
    124.727
    ];

timenum = datenum(yyyy_all(1),1,1):datenum(yyyy_all(end),12,31);
SST_daily = NaN(length(stations), [yeardays(yyyy_all(1))+yeardays(yyyy_all(end))]);
for si = 1:length(stations)
    station = stations{si};
    id = ids(si);
    idstr = num2str(id);
    lat = lats(si);
    lon = lons(si);

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi);
        ystr = num2str(yyyy);

        filename = [idstr, 'h', ystr, '.txt'];
        file = [filepath, filename];
        try
            data = readmatrix(file);
        catch
            continue
        end
        SST_tmp = data(:,15);
        SST_tmp(SST_tmp == 999.0) = NaN;
        timenum_tmp = datenum(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),0);
        timenum_tmp_daily = floor(timenum_tmp);
        for ti = 1:length(timenum)
            tindex = find(timenum_tmp_daily == timenum(ti));
            if ~isempty(tindex)
                SST_tmp_daily = mean(SST_tmp(tindex), 'omitnan');
                SST_daily(si,ti) = SST_tmp_daily;
            end
        end % ti
    end % yi
end % si

save('SST_buoy_daily.mat', 'stations', 'ids', 'lats', 'lons', 'timenum', 'SST_daily')