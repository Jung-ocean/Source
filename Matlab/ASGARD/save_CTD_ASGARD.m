%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save CTD ASGARD data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

period = datenum(2017,6,1):datenum(2019,8,31);

points = [1 2 3 4];
points_name = {'N1', 'N2', 'N3', 'N4'};
points_location = [;
    63.2965, -168.43;
    64.1545, -171.526;
    64.3895, -167.086;
    64.9284, -169.9182;
    ];

% Observation
filepath_obs = '/data/jungjih/Observations/CTD/ASGARD/';

ci = 1;
for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    point_location = points_location(point,:);
    point_lat = point_location(1);
    point_lon = point_location(2);
    filenames_obs = dir([filepath_obs, '*', point_name, '*']);

    for fi = 1:length(filenames_obs)
        filename_obs = filenames_obs(fi).name;
        file_obs = [filepath_obs, filename_obs];
        data = readtable(file_obs);

        timenum = [];
        temp = [];
        salt = [];
        switch filename_obs
            case 'ASGARD_17_N1_SBE16_sn07051_26m.dat'
                startindex = 454;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

            case 'ASGARD_17_N1_SBE37_sn00252_38m.dat'
                startindex = 149;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_18_N1_SBE16_sn07052_30m.dat'
                startindex = 480;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

            case 'ASGARD_18_N1_SBE37_sn15644_41m.dat'
                startindex = 236;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N2_SBE16_sn04639_25m.dat'
                startindex = 515;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N2_SBE37_sn00709_35m.dat'
                startindex = 151;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N2_SBE37_sn03389_41m.dat'
                startindex = 163;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_18_N2_SBE16_sn06050_25m.dat'
                startindex = 103;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_18_N2_SBE37_sn15790_40m.dat'
                startindex = 297;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

            case 'ASGARD_18_N2_SBE37_sn16399_35m.dat'
                startindex = 235;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

            case 'ASGARD_17_N3_SBE16_sn04973_24m.dat'
                startindex = 106;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N4_SBE16_sn04787_27m.dat'
                startindex = 121;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N4_SBE37_sn00454_35m.dat'
                startindex = 150;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_17_N4_SBE37_sn04600_44m.dat'
                startindex = 163;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_18_N4_SBE16_sn04784_25m.dat'
                startindex = 103;
                data_mat = cell2mat(table2array(data(startindex:end,1)));
                yyyy = data_mat(:,1:4);
                mm = data_mat(:,5:7);
                dd = data_mat(:,8:10);
                HH = data_mat(:,11:13);
                MM = data_mat(:,14:16);
                temp_str = data_mat(:,61:66);
                salt_str = data_mat(:,79:84);

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy(i,:)), str2num(mm(i,:)), str2num(dd(i,:)), str2num(HH(i,:)), str2num(MM(i,:)), 0);
                    temp(i) = str2num(temp_str(i,:));
                    salt(i) = str2num(salt_str(i,:));
                end

            case 'ASGARD_18_N4_SBE37_sn09675_35m.dat'
                startindex = 208;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

            case 'ASGARD_18_N4_SBE37_sn16398_44m.dat'
                startindex = 166;
                yyyy = table2array(data(startindex:end,1));
                mm = table2array(data(startindex:end,2));
                dd = table2array(data(startindex:end,3));
                HH = table2array(data(startindex:end,4));
                MM = table2array(data(startindex:end,5));
                temp_cell = table2array(data(startindex:end,11));
                salt_cell = table2array(data(startindex:end,13));

                for i = 1:length(yyyy)
                    timenum(i) = datenum(str2num(yyyy{i}), str2num(mm{i}), str2num(dd{i}), str2num(HH{i}), str2num(MM{i}), 0);
                    temp(i) = str2num(temp_cell{i});
                    salt(i) = str2num(salt_cell{i});
                end

        end

        CTD(ci).filename = filename_obs;
        CTD(ci).timenum = timenum;
        CTD(ci).temp = temp;
        CTD(ci).salt = salt;
        CTD(ci).lat = point_lat;
        CTD(ci).lon = point_lon;
        CTD(ci).depth = str2num(filename_obs(end-6:end-5));

        ci = ci+1;
    end % fi
end % pi

save CTD_ASGARD.mat CTD