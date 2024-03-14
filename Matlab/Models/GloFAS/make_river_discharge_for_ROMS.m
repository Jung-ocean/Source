%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make river discharge for ROMS forcing based on the GloFAS data
% You will need "river_source_points.mat" and "river_mouth_point.m" files
% "river_source_points.mat" file is output from "prepare_river_source_points.m"
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
major_rivers = {'Anadyr', 'Yukon', 'Kamchatka', 'Kuskokwim', 'Nushagak', 'Kvichak'};
yyyy_all = [2017:2022]; % 9999 = climate
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

    dis_points_all = zeros(length(lat_point),yeardays(yyyy));
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

%         if size(dis_points,1) == 366
%             dis_points(60) = []; % Removing 29th of February
%         end

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

    dis_majors_all = zeros(length(major_rivers),yeardays(yyyy));
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

%         if size(dis_majors,1) == 366
%             dis_majors(60) = []; % Removing 29th of February
%         end

        dis_majors_all(ri,:) = dis_majors;
    end
    
    index_main = [];
    lat_major_actual = zeros(length(major_rivers),1);
    lon_major_actual = zeros(length(major_rivers),1);
    for ri = 1:length(major_rivers)
        lat_major = lat_major_all{ri};
        lon_major = lon_major_all{ri};

        index1 = find(ismember(lat_point, lat_major)==1);
        index2 = find(ismember(lon_point, lon_major)==1);

        index1_chk = find(ismember(index1,index2));
        index2_chk = find(ismember(index2,index1));

        index_lat = index1(index1_chk);
        index_lon = index2(index2_chk);

        if isequal(index_lat,index_lon)
            index_main = [index_main; index_lat];
        end
        lat_major_actual(ri) = mean(lat_major);
        lon_major_actual(ri) = mean(lon_major);
    end
    
    dis_points_others = dis_points_all;
    dis_points_others(index_main,:) = [];
    lat_points_others = lat_point;
    lat_points_others(index_main) = [];
    lon_points_others = lon_point;
    lon_points_others(index_main) = [];

    save(['river_discharge_GloFAS_', ystr, '.mat'], 'major_rivers', 'lat_major_actual', 'lon_major_actual', 'dis_majors_all', 'lat_points_others', 'lon_points_others', 'dis_points_others');
    disp([ystr, '...'])
end