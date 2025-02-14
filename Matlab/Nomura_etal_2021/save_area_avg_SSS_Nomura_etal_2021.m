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

% Gulf of Anadyr
polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];

for i = 1:length(data)
    lon(i) = data(i).longitude-360;
    lat(i) = data(i).latitude;
end

[in, on] = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
index = find(in);

for ii = index
    datestr(data(ii).date)
    salt(ii) = data(ii).salt(1);
end
salt(salt == 0) = [];
SSS_mean = mean(salt);
SSS_std = std(salt);

save(['SSS_Gulf_of_Anadyr_Nomura_etal_2021.mat'], 'data', 'SSS_mean', 'SSS_std');