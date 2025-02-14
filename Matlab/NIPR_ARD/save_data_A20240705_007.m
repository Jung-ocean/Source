clear; clc

filepath = '/data/jungjih/Observations/NIPR_ARD/A20240705-007/DATA/';
filename = 'Data-underway-biogeochemical.csv';
file = [filepath, filename];
data_all = readtable(file);
data_all(78:end,:) = [];

si = 0;
for fi = 1:height(data_all)
    si = si+1;

    station_tmp = string(table2cell(data_all(fi,1)));
    data(si).station = station_tmp;
    timenum_tmp = table2cell(data_all(fi,2));
    data(si).date = datenum(timenum_tmp, 'yyyy/m/dd')
    data(si).latitude = cell2mat(table2cell(data_all(fi,3)));
    data(si).longitude = cell2mat(table2cell(data_all(fi,4)));
    data(si).temp = cell2mat(table2cell(data_all(fi,5)));
    data(si).salt = cell2mat(table2cell(data_all(fi,6)));
end

lon = [];
lat = [];
timenum = [];
for i = 1:length(data)
    stations{i} = data(i).station;
   
    lon(i) = data(i).longitude;
    lat(i) = data(i).latitude;
    timenum(i) = data(i).date;
    SSS(i) = data(i).salt;
end

figure; plot_map('Gulf_of_Anadyr', 'mercator', 'l')
s = scatterm(lat, lon, 50, SSS, 'filled', 'MarkerEdgeColor', 'k');
colormap jet
caxis([29 34])
c = colorbar;
textm(lat, lon, stations);

save(['data_NIPR_ARD_2023.mat'], 'data', 'lat', 'lon', 'timenum', 'SSS');