clear; clc

filename = ['1-s2.0-S0079661121000823-mmc1.xlsx'];

data_all = readtable(filename);

si = 0;
ind_start = 1;

for i = 1:height(data_all)

    if i+3 > height(data_all)
        ind_end = height(data_all);

        pressure_db = [];
        temp = [];
        salt = [];
        O18 = [];
        for di = ind_start:ind_end
            pressure_db = [pressure_db; str2num(string(table2cell(data_all(di,2))))];
            temp = [temp; str2num(string(table2cell(data_all(di,3))))];
            salt = [salt; str2num(string(table2cell(data_all(di,4))))];
            O18 = [O18; str2num(string(table2cell(data_all(di,5))))];
        end

        data(si).pressure_db = pressure_db;
        data(si).temp = temp;
        data(si).salt = salt;
        data(si).O18 = O18;

        break
    else

        data1 = string(table2cell(data_all(i,1)));
        data2 = string(table2cell(data_all(i+1,1)));
        data3 = char(table2cell(data_all(i+2,1)));
        data4 = char(table2cell(data_all(i+3,1)));

        if ~isempty(data3) & ~isempty(data4) & strcmp(data3(end), 'N') & strcmp(data4(end), 'E')

            si = si+1;
            data(si).station = data1;
            data(si).date = datenum(data2);
            data(si).latitude = str2num(data3(1:end-1));
            data(si).longitude = str2num(data4(1:end-1));

            if si > 1
                ind_end = i-1;
                pressure_db = [];
                temp = [];
                salt = [];
                O18 = [];
                for di = ind_start:ind_end
                    pressure_db = [pressure_db; str2num(string(table2cell(data_all(di,2))))];
                    temp = [temp; str2num(string(table2cell(data_all(di,3))))];
                    salt = [salt; str2num(string(table2cell(data_all(di,4))))];
                    O18 = [O18; str2num(string(table2cell(data_all(di,5))))];
                end

                data(si-1).pressure_db = pressure_db;
                data(si-1).temp = temp;
                data(si-1).salt = salt;
                data(si-1).O18 = O18;

                ind_start = i;
            end
        end

    end
end

for i = 1:length(data)
    stations{i} = data(i).station;
   
    lon(i) = data(i).longitude;
    if lon(i) > 0
        lon(i) = lon(i)-360;
    end
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

save(['data_Nomura_etal_2021_2018.mat'], 'data', 'lat', 'lon', 'timenum', 'depth', 'SSS');