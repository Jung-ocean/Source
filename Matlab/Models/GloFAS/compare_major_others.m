%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare river discharge between major rivers and other
% You will need "river_source_points.mat" and "river_mouth_point.m" files
% "river_source_points.mat" file is output from "prepare_river_source_points.m"
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
major_rivers = {'Anadyr', 'Yukon', 'Kamchatka', 'Kuskokwim', 'Nushagak', 'Kvichak'};
yyyy_all = [9999, 2016:2022]; % 9999 = climate
filepath_all = '/data/jungjih/Model/GloFAS/';
river_source_points = 'river_source_points.mat';
dist_radius = 0.3;
%

points = load(river_source_points);
lat_point = points.lat_dis_target;
lon_point = points.lon_dis_target;

% Major river latitude and longitude
lat_major_all = cell(length(major_rivers),1);
lon_major_all = cell(length(major_rivers),1);
for ri = 1:length(major_rivers)
    river = major_rivers{ri};
    [lon, lat] = river_mouth_point(river);

    dist = distance(lat, lon, lat_point, lon_point);
    index = find(dist < dist_radius);
    lat_major_all{ri} = lat_point(index);
    lon_major_all{ri} = lon_point(index);
end

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    filepath = [filepath_all, ystr, '/'];
    if yyyy == 9999
        filepath = [filepath_all, 'climate/'];
    end
    filenames = dir([filepath, '*.nc']);

    latitude = ncread([filepath,filenames(1).name], 'lat');
    longitude = ncread([filepath,filenames(1).name], 'lon');

    dis_points_all = zeros(length(lat_point),365);
    for pi = 1:length(lat_point)
        latind = find(latitude == lat_point(pi));
        lonind = find(longitude == lon_point(pi));

        if lon_point(pi) > 190
            EW_check(pi) = 'E';
        else
            EW_check(pi) = 'W';
        end

        dis_points = zeros(yeardays(yyyy),1);
        daynums = [0, cumsum(eomday(yyyy,1:12))];
        for fi = 1:length(filenames)
            filename = filenames(fi).name;
            file = [filepath, filename];
            dis_point = zeros;
            for i = 1:length(latind)
                dis24 = ncread(file,'dis24',[lonind(i) latind(i) 1], [1 1 Inf]);
                dis_point = dis24;
            end

            daynum = (daynums(fi)+1):daynums(fi+1);
            dis_points(daynum) = dis_point;
        end

        if size(dis_points,1) == 366
            dis_points(60) = []; % Removing 29th of February
        end

        dis_points_all(pi,:) = dis_points;
    end

    % Major river
    % Major river indices
    lat_major_indices = cell(length(major_rivers),1);
    lon_major_indices = cell(length(major_rivers),1);
    for ri = 1:length(major_rivers)
        lat_major = lat_major_all{ri};
        lon_major = lon_major_all{ri};
        for mi = 1:length(lat_major)
            lat_major_indices{ri}(mi) = find(latitude == lat_major(mi));
            lon_major_indices{ri}(mi) = find(longitude == lon_major(mi));
        end
    end

    dis_majors_all = zeros(length(major_rivers),365);
    for ri = 1:length(major_rivers)
        lat_major_ind = lat_major_indices{ri};
        lon_major_ind = lon_major_indices{ri};

        if lon_major_all{ri}(1) > 190
            EW_check_major(ri) = 'E';
        else
            EW_check_major(ri) = 'W';
        end

        dis_majors = zeros(yeardays(yyyy),1);
        for fi = 1:length(filenames)
            filename = filenames(fi).name;
            file = [filepath, filename];
            dis_major = zeros;
            for i = 1:length(lat_major_ind)
                dis24 = ncread(file,'dis24',[lon_major_ind(i) lat_major_ind(i) 1], [1 1 Inf]);
                dis_major = dis_major + dis24;
            end

            daynum = (daynums(fi)+1):daynums(fi+1);
            dis_majors(daynum) = dis_major;
        end

        if size(dis_majors,1) == 366
            dis_majors(60) = []; % Removing 29th of February
        end

        dis_majors_all(ri,:) = dis_majors;
    end

    % Plot
    figure; hold on
    if yyyy == 9999
        sgtitle('Climate');
    else
        sgtitle(ystr)
    end

    colors = [0 0.4470 0.7410;
        0.8500 0.3250 0.0980;
        0.9290 0.6940 0.1250;
        0.4940 0.1840 0.5560;
        0.4660 0.6740 0.1880;
        0.3010 0.7450 0.9330];
    color_other = [.8 .8 .8];

    dis_points_sum = sum(dis_points_all,1);
    dis_majors_sum = sum(dis_majors_all,1);
    dis_points_sum_wo_majors = dis_points_sum - dis_majors_sum;

    Wpoints_index = find(ismember(EW_check,'W') == 1);
    Wmajors_index = find(ismember(EW_check_major,'W') == 1);
    dis_Wpoints_sum = sum(dis_points_all(Wpoints_index,:),1);
    dis_Wmajor_sum = sum(dis_majors_all(Wmajors_index,:),1);
    dis_Wpoints_sum_wo_Wmajors = dis_Wpoints_sum - dis_Wmajor_sum;

    Epoints_index = find(ismember(EW_check,'E') == 1);
    Emajors_index = find(ismember(EW_check_major,'E') == 1);
    dis_Epoints_sum = sum(dis_points_all(Epoints_index,:),1);
    dis_Emajor_sum = sum(dis_majors_all(Emajors_index,:),1);
    dis_Epoints_sum_wo_Emajors = dis_Epoints_sum - dis_Emajor_sum;

    subplot(3,1,1); hold on; grid on;

    ptotal = plot(1:365, dis_points_sum, 'k', 'LineWidth', 2);
    for ri = 1:length(major_rivers)
        p(ri) = plot(1:365, dis_majors_all(ri,:), 'Color', [colors(ri,:)], 'LineWidth', 2);
    end
    pothers = plot(1:365,dis_points_sum_wo_majors, '--k', 'LineWidth', 2);

    xtick_list = [1 cumsum(eomday(0,1:12))+1];
    xticks(xtick_list(1:end));
    datetick('x', 'mmm', 'keepticks')
    xlim([0 366])
    ylim([0 10e4])
%     ylabel('River discharge (m^3/s)')
    set(gca, 'FontSize', 15)

    l = legend([ptotal, p, pothers], ['All', major_rivers, 'others']);
    l.Location = 'NorthWest';
    l.NumColumns = 2;

    title('Total');

    % West
    subplot(3,1,2); hold on; grid on;
    clearvars p

    ptotal = plot(1:365, dis_Wpoints_sum, 'k', 'LineWidth', 2);
    for ri = 1:length(Wmajors_index)
        p(ri) = plot(1:365, dis_majors_all(Wmajors_index(ri),:), 'Color', [colors(Wmajors_index(ri),:)], 'LineWidth', 2);
    end
    pothers = plot(1:365,dis_Wpoints_sum_wo_Wmajors, '--k', 'LineWidth', 2);

    xtick_list = [1 cumsum(eomday(0,1:12))+1];
    xticks(xtick_list(1:end));
    datetick('x', 'mmm', 'keepticks')
    xlim([0 366])
    ylim([0 7e4])
    ylabel('River discharge (m^3/s)')
    set(gca, 'FontSize', 15)
    
    title('West');

    % East
    subplot(3,1,3); hold on; grid on;
    clearvars p

    ptotal = plot(1:365, dis_Epoints_sum, 'k', 'LineWidth', 2);
    for ri = 1:length(Emajors_index)
        p(ri) = plot(1:365, dis_majors_all(Emajors_index(ri),:), 'Color', [colors(Emajors_index(ri),:)], 'LineWidth', 2);
    end
    pothers = plot(1:365,dis_Epoints_sum_wo_Emajors, '--k', 'LineWidth', 2);

    xtick_list = [1 cumsum(eomday(0,1:12))+1];
    xticks(xtick_list(1:end));
    datetick('x', 'mmm', 'keepticks')
    xlim([0 366])
    ylim([0 4e4])
%     ylabel('River discharge (m^3/s)')
    set(gca, 'FontSize', 15)
    
    title('East');

    set(gcf, 'Position', [0 0 1200 1000]);
    set(gcf, 'PaperPosition', [-1.6250 0.5156 11.7500 9.9688])
    set(gcf, 'PaperSize', [8.5000 11.0000])
    set(gcf, 'PaperPositionMode', 'auto');
    pause(3)
    print(strcat('Compare_major_others_' , ystr),'-dpng');
end