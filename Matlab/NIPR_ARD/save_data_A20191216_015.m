clear; clc

load station.mat

filepath = '/data/jungjih/Observations/NIPR_ARD/A20191216-015/';

filenames1 = dir([filepath, 'C040_Leg3_CTDdata/*.asc']);
filenames2 = dir([filepath, 'C040_Leg4_CTDdata/*.asc']);
filenames = [filenames1; filenames2];

startRow = 2;
formatSpec = '%11f%11f%11f%11f%11f%11f%11f%11f%11f%11f%11f%f%[^\n\r]';

si = 0;
for fi = 1:length(filenames)
    si = si+1;

    file = [filenames(fi).folder, '/', filenames(fi).name];
    station_tmp = file(end-10:end-4);

    fileID = fopen(file,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    dataset = table(dataArray{1:end-1}, 'VariableNames', {'PrDM','T090C','C0Sm','Sbeox0MLL','FlSP','AltM','CStarTr0','Sal00','Sigmat00','SvDM','Potemp090C','Sigma00'});

    depth = cell2mat(table2cell(dataset(:,1)));
    temp = cell2mat(table2cell(dataset(:,11)));
    salt = cell2mat(table2cell(dataset(:,8)));

    data(si).temp = temp;
    data(si).salt = salt;
    data(si).pressure_db = depth;

    index = find(strcmp(station_tmp, station) == 1);

    data(si).station = station_tmp;
    data(si).date = timenum(index);
    data(si).latitude = lat(index);
    data(si).longitude = lon(index);
end

lon = [];
lat = [];
timenum = [];
for i = 1:length(data)
    stations{i} = data(i).station;
   
    lon(i) = data(i).longitude;
    lat(i) = data(i).latitude;
    timenum(i) = data(i).date;
    depth(i) = max(data(i).pressure_db);
    index = find(data(i).pressure_db == min(data(i).pressure_db));
    SSS(i) = data(i).salt(index);
end

figure; plot_map('Gulf_of_Anadyr', 'mercator', 'l')
s = scatterm(lat, lon, 50, SSS, 'filled', 'MarkerEdgeColor', 'k');
colormap jet
caxis([29 34])
c = colorbar;
textm(lat, lon, stations);

save(['data_NIPR_ARD_2017.mat'], 'data', 'lat', 'lon', 'timenum', 'depth', 'SSS');