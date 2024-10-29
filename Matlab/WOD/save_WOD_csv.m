clear; clc

dataset = 'OSD';
filename = ['ocldb1729277135.1117149.', dataset, '.csv'];

data_all = read_WOD_csv(filename);

info = string(table2cell(data_all(:,1)));
depth_all = string(table2cell(data_all(:,2)));
infodata = string(table2cell(data_all(:,3)));

yindex = find(strcmp(info, 'Year'));
mindex = find(strcmp(info, 'Month'));
dindex = find(strcmp(info, 'Day'));
latind = find(strcmp(info, 'Latitude'));
lonind = find(strcmp(info, 'Longitude'));
depind = find(strcmp(depth_all, '5.0') | strcmp(depth_all, '5.'));
salt_all = string(table2cell(data_all(depind,5)));

for i = 1:length(yindex)
    yyyy(i) = str2num(infodata(yindex(i)));
    mm(i) = str2num(infodata(mindex(i)));
    dd(i) = str2num(infodata(dindex(i)));
    lat(i) = str2num(infodata(latind(i)));
    lon(i) = str2num(infodata(lonind(i)));
    try
        SSS(i) = str2num(salt_all(i));
    catch
        SSS(i) = NaN;
    end
end

% Gulf of Anadyr
polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];

yyyy_all = [];
SSS_mean = [];
SSS_std = [];
for yi = 1950:2024
    index = find(yyyy == yi & mm == 7);
    if isempty(index)

    else
        lat_target = lat(index);
        lon_target = lon(index);
        SSS_target = SSS(index);

         [in, on] = inpolygon(lon_target, lat_target, polygon(:,1), polygon(:,2));
        if sum(in) > 0
            yyyy_all = [yyyy_all; yi];
            SSS_mean = [SSS_mean; nanmean(SSS(in))];
            SSS_std = [SSS_std; nanstd(SSS(in))];
            disp([num2str(yi), ' ', num2str(SSS_mean(end))]);
        end

    end
end

figure; hold on; grid on
errorbar(yyyy_all, SSS_mean, SSS_std, 'o');

save(['WOD_', dataset, '.mat'], 'yyyy_all', 'SSS_mean', 'SSS_std')