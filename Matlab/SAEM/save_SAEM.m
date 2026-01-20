clear; clc

Hydrosat_number = 31213702166006;
Station = '2901201';
lat = 65.45;
lon = 172.97;

file = 'SAEM_Discharge_V01_1.nc';
Gauge_Name = string(ncread(file, 'Gauge_Name'));
Gauge_Name = replace(Gauge_Name, ' ', '');
index = find(strcmp(Gauge_Name, Station));

time_tmp = ncread(file, 'Time');
timenum = datenum(time_tmp + datenum(1995,1,1));
lon = ncread(file, 'Gauge_Lon', [index], [1]);
lat = ncread(file, 'Gauge_Lat', [index], [1]);
dis = ncread(file, 'EstimatedDischarge', [1 index], [Inf 1]);

figure; hold on; grid on;
plot(timenum, dis, 'o');
xticks([datenum(2019:2023,1,1)])
datetick('x', 'mmm, yyyy', 'keepticks')

save(['dis_', Station, '.mat'], 'Station', 'timenum', 'dis', 'lon', 'lat')