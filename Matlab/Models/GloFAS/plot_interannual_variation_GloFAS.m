%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot interannual variation of river discharge using GloFAS data
% You will need "river_source_points.mat" and "river_mouth_point.m" files
% "river_source_points.mat" file is output from "prepare_river_source_points.m"
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
yyyy_all = [9999, 2013:2023]; % 9999 = climate
filepath_all = '/data/jungjih/Models/GloFAS/';
river_source_points = 'river_source_points.mat';
river = 'Anadyr';
dist_radius = 0.3;
%

points = load(river_source_points);
lat_point = points.lat_dis_target;
lon_point = points.lon_dis_target;

[lon, lat] = river_mouth_point(river);
dist = distance(lat, lon, lat_point, lon_point);
index = find(dist < dist_radius);
lat_target = lat_point(index);
lon_target = lon_point(index);

figure; hold on; grid on;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    filepath = [filepath_all, ystr, '/'];
    if yyyy == 9999
        filepath = [filepath_all, 'climate/'];
    end
    filenames = dir([filepath, '*.nc']);

    latitude = ncread([filepath,filenames(1).name], 'lat');
    longitude = ncread([filepath,filenames(1).name], 'lon');

    latind = [];
    lonind = [];
    for i = 1:length(lat_target)
        latdist = abs(latitude - lat_target(i));
        londist = abs(longitude - lon_target(i));

        latind(i) = find(latdist == min(latdist));
        lonind(i) = find(londist == min(londist));
        if min(latdist) > 0.00001 | min(londist) > 0.00001
            error('Check the lat and lon indices')
        end
    end

    dis_total = zeros(yeardays(yyyy),1);
    daynums = [0, cumsum(eomday(yyyy,1:12))];
    for fi = 1:length(filenames)
        filename = filenames(fi).name;
        mm_str = filename(17:18);
        file = [filepath, filename];
        dis_area_sum = zeros;
        for i = 1:length(latind)
            dis24 = ncread(file,'dis24',[lonind(i) latind(i) 1], [1 1 Inf]);
            dis_area_sum = dis_area_sum + dis24;
        end
        daynum = (daynums(fi)+1):daynums(fi+1);
        dis_total(daynum) = squeeze(dis_area_sum);
    end

    if size(dis_total,1) == 366
        dis_total(60) = []; % Removing 29th of February
    end
    
    p(yi) = plot(1:365, dis_total, 'Color', [.7 .7 .7]);
    disp([ystr, '... ', num2str(sum(dis_total), '%.2e')])
end

index1 = find(yyyy_all == 9999);
p(index1).Color = 'k';
p(index1).LineWidth = 2;
l = legend([p(index1)], 'Climate (1979-2023)');
l.Location = 'NorthWest';
l.FontSize = 15;

if sum(ismember(2017:2020, yyyy_all)) == 4
%     index2015 = find(yyyy_all == 2015);
%     p(index2015).Color = 'y';
%     p(index2015).LineWidth = 2;
% 
    index2016 = find(yyyy_all == 2016);
    p(index2016).Color = [0.9294 0.6941 0.1255];
    p(index2016).LineWidth = 2;
     
    index2017 = find(yyyy_all == 2017);
    p(index2017).Color = 'r';
    p(index2017).LineWidth = 2;

    index2018 = find(yyyy_all == 2018);
    p(index2018).Color = 'g';
    p(index2018).LineWidth = 2;

    index2019 = find(yyyy_all == 2019);
    p(index2019).Color = 'b';
    p(index2019).LineWidth = 2;

    index2020 = find(yyyy_all == 2020);
    p(index2020).Color = 'm';
    p(index2020).LineWidth = 2;

    index2021 = find(yyyy_all == 2021);
    p(index2021).Color = [1.0000 0.4118 0.1608];
    p(index2021).LineWidth = 2;

    index2022 = find(yyyy_all == 2022);
    p(index2022).Color = [0.4941 0.1843 0.5569];
    p(index2022).LineWidth = 2;    

    index2023 = find(yyyy_all == 2023);
    p(index2023).Color = [0.3020 0.7451 0.9333];
    p(index2023).LineWidth = 2;    

    l = legend([p(index1), p(index2016), p(index2017), p(index2018), p(index2019), p(index2020), p(index2021), p(index2022), p(index2023), p(2)], 'Climate (1979-2023)', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', 'others');
    l.Location = 'NorthWest';
    l.FontSize = 15;
end

xtick_list = [1 cumsum(eomday(0,1:12))+1];
xticks(xtick_list(1:end));
datetick('x', 'mmm', 'keepticks')

xlim([0 366])
ylim([0 3.5e4])

ylabel('River discharge (m^3/s)')
set(gca, 'FontSize', 15)

yyyy_title = yyyy_all(yyyy_all < 3000);

t = title([river, ' (', num2str(dist_radius), ' degree sum) from ', num2str(yyyy_title(1)), ' to ', num2str(yyyy_title(end))]);

set(gcf, 'Position', [20 300 1200 600]);
set(gcf, 'PaperPosition', [-2.0000 2.3750 12.5000 6.2500])
set(gcf, 'PaperSize', [8.5 11.0])
pause(3)
kk
print(['Interannual_', river],'-dpng');