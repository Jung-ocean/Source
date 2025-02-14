clear; clc

filepath = '/data/jungjih/Observations/NIPR_ARD/A20191216-015/';
filename = 'C040-Leg3-4 CTD Log Sheets_ADS.xlsx';
file = [filepath, filename];

data_all = readtable(filename);
data_all(225:end,:) = [];

station = string(table2cell(data_all(:,1)));
lat_str = string(table2cell(data_all(:,5)));
lon_str = string(table2cell(data_all(:,6)));
date = string(table2cell(data_all(:,7)));

for i = 1:length(station)
    lat_tmp = char(lat_str(i));
    lat(i) = str2num(lat_tmp(1:2)) + str2num(lat_tmp(3:end-1))/60;
    lon_tmp = char(lon_str(i));
    lon(i) = str2num(lon_tmp(1:3)) + str2num(lon_tmp(4:end-1))/60;
    if strcmp(lon_tmp(end), 'E')
        lon(i) = lon(i)-360;
    else
        lon(i) = -lon(i);
    end
    try
        timenum(i) = datenum(date(i), 'mmm dd yyyy');
    catch
        timenum(i) = datenum(date(i), 'dd-mmm-yyyy');
    end
end

save station.mat station lat lon timenum