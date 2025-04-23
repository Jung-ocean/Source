%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Process buoy data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2023:2024;
mm_all = 1:12;
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

ids_target = [46097, 46099, 46100];
index = find(ismember(ids, ids_target) == 1);
stations = stations(index);
ids = ids(index);
lats = lats(index);
lons = lons(index);

SSS_monthly = NaN(length(stations), 12*length(yyyy_all));
for si = 1:length(stations)
    station = stations{si};
    id = ids(si);
    idstr = num2str(id);
    lat = lats(si);
    lon = lons(si);

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi);
        ystr = num2str(yyyy);

        filename = [idstr, 'o', ystr, '.txt'];
        file = [filepath, filename];
        try
            data = readmatrix(file);
        catch
            continue
        end

        SSS_tmp = data(:,9);
        SSS_tmp(SSS_tmp == 99) = NaN;
        timenum_tmp = datenum(data(:,1),data(:,2),data(:,3),data(:,4),data(:,5),0);
        timevec_tmp = datevec(timenum_tmp);

        for mi = 1:length(mm_all)
            mm = mm_all(mi);

            tindex = find(timevec_tmp(:,1) == yyyy & timevec_tmp(:,2) == mm);
            if ~isempty(tindex)
                SSS_tmp_monthly = mean(SSS_tmp(tindex), 'omitnan');
                SSS_monthly(si,(yi-1)*12 + mi) = SSS_tmp_monthly;
            end
        end
    end % yi
end % si

timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    timenum = [timenum datenum(yyyy,1:12,1)];
end

save('SSS_buoy_monthly.mat', 'stations', 'ids', 'lats', 'lons', 'timenum', 'SSS_monthly')