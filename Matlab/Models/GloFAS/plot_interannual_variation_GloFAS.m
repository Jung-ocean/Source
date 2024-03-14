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
yyyy_all = [9999, 2013:2022]; % 9999 = climate
filepath_all = '/data/jungjih/Models/GloFAS/';
river_source_points = 'river_source_points.mat';
river = 'Yukon';
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

    for i = 1:length(lat_target)
        latind(i) = find(latitude == lat_target(i));
        lonind(i) = find(longitude == lon_target(i));
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
    index2015 = find(yyyy_all == 2015);
    p(index2015).Color = 'y';
    p(index2015).LineWidth = 2;
    
    index2016 = find(yyyy_all == 2016);
    p(index2016).Color = [0.4941 0.1843 0.5569];
    p(index2016).LineWidth = 2;
    
    index2 = find(yyyy_all == 2017);
    p(index2).Color = 'r';
    p(index2).LineWidth = 2;

    index3 = find(yyyy_all == 2018);
    p(index3).Color = 'g';
    p(index3).LineWidth = 2;

    index4 = find(yyyy_all == 2019);
    p(index4).Color = 'b';
    p(index4).LineWidth = 2;

    index5 = find(yyyy_all == 2020);
    p(index5).Color = 'm';
    p(index5).LineWidth = 2;

    index2021 = find(yyyy_all == 2021);
    p(index2021).Color = [1.0000 0.4118 0.1608];
    p(index2021).LineWidth = 2;

    l = legend([p(index1),p(index2015), p(index2016), p(index2), p(index3), p(index4), p(index5), p(index2021), p(end)], 'Climate (1979-2023)', '2015', '2016', '2017', '2018', '2019', '2020', '2021', 'others');
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
print(['Interannual_', river],'-dpng');