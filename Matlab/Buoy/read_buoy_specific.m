clear; clc

yyyy_all = 2020:2020;
station = '생일도'

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

switch station
    case '남해동부'
        filecode = 'TW_KG_KG_0025';
        modeldata = [ystr, '_SE.mat'];
    case '대한해협'
        filecode = 'TW_KG_KG_0024';
    case '통영'
        filecode = 'TW_TW_TONGYEONG';
    case '생일도'
        filecode = 'TW_TW_SAENGIL';
        modeldata = [ystr, '_SI.mat'];
    case '여수'
        filecode = 'TW_TW_YEOSU';
end

filepath = 'D:\Data\Ocean\Buoy\해양관측부이\';
filename = ['data_', ystr, '_', filecode, '_', ystr, '_KR'];
file = [filepath, filename];

data = read_buoy_function(file);
yyyymmddHH = data{:,1};
time = datenum(yyyymmddHH) - 9/24; timenum = time;
timevec = datevec(time);

xticks = datenum(yyyy,1:12,1,0,0,0);

speed = []; direction = [];
windspeed = []; winddirection = [];
for i = 1:size(timevec,1)
    try % current
        speed(i) = str2num(char(data{i,2}));
        direction(i) = str2num(char(data{i,4}));
    catch
        speed(i) = NaN;
        direction(i) = NaN;
    end
    try % wind
        windspeed(i) = str2num(char(data{i,13}));
        winddirection(i) = str2num(char(data{i,15}));
    catch
        windspeed(i) = NaN;
        winddirection(i) = NaN;
    end
    
end

degree = 90-direction;
degree(degree < 0) = degree(degree < 0) + 360;

u = speed.*cosd(degree);
v = speed.*sind(degree);

winddegree = 90-winddirection;
winddegree(winddegree < 0) = winddegree(winddegree < 0) + 360;

uwind = -windspeed.*cosd(winddegree); % - sign for matching with current direction
vwind = -windspeed.*sind(winddegree);

%%%%%
% figure; hold on; grid on
% plot(time, u, '.-')
% datetick('x')
% ylabel('cm/s')
% 
% title(['Zonal velocity ', station, ' ', ystr])
%%%%%
% umean = nanmean(u); ustd = nanstd(u);
% u(u > umean + 3*ustd) = NaN;
% u(u < umean - 3*ustd) = NaN;

timenum_unique = unique(floor(time));
clearvars u_daily v_daily
for ti = 1:length(timenum_unique)
    index = find(floor(time) == timenum_unique(ti));
    u_daily(ti) = nanmean(u(index));
    v_daily(ti) = nanmean(v(index));
end

   xtick_list = [datenum(yyyy,1:12,1)];
    
    load([modeldata])
    timenum_model1 = [datenum(yyyy,1,1):datenum(yyyy,12,31)];
    u_surf_target1 = u_surf_target*100;
       
    figure; hold on; grid on
    p1 = plot(timenum_unique, u_daily, 'r', 'LineWidth', 1);
    p2 = plot(timenum_model1, u_surf_target1, 'g', 'LineWidth', 1);
    set(gca, 'xtick', xtick_list)
    ylim([-100 100])
    datetick('x', 'mmm-dd', 'keepticks');
    xlim([datenum(yyyy,6,1) datenum(yyyy,9,30)]);
    ylabel('cm/s')
    l = legend([p1, p2], 'Observation', 'Model (6-8 km)');
    l.Location = 'SouthWest';
    title([station, ' (daily)'], 'interpreter', 'none')
    set(gca, 'FontSize', 15)

    saveas(gcf, [ystr, '_', station, '_obs_vs_model_daily.png'])
    
    %%%%%
    u_daily = fillmissing(u_daily, 'linear');
    figure; hold on; grid on
    p1 = plot(timenum_unique, movmean(u_daily, 14), 'r', 'LineWidth', 1);
    p2 = plot(timenum_model1, movmean(u_surf_target1, 14), 'g', 'LineWidth', 1);
    set(gca, 'xtick', xtick_list)
    ylim([-70 70])
    datetick('x', 'mmm-dd', 'keepticks');
    xlim([datenum(yyyy,6,1) datenum(yyyy,9,30)]);
    ylabel('cm/s')
    l = legend([p1, p2], 'Observation', 'Model (6-8 km)');
    l.Location = 'SouthWest';
    title([station, ' (daily)'], 'interpreter', 'none')
    set(gca, 'FontSize', 15)

    saveas(gcf, [ystr, '_', station, '_obs_vs_model_14d_movmean.png'])
    
end