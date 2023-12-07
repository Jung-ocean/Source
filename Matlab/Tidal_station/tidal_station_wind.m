clear; clc

yyyy_all = 2020:2020;
station = '거문도';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

switch station
    case '거문도'
        filecode = 'DT_DT_10';
end

filepath = 'D:\Data\Ocean\조위관측소\wind\';
filename = ['data_', ystr, '_', filecode, '_', ystr, '_KR'];
file = [filepath, filename];

data = tidal_station_wind_function(file);
yyyymmddHH = data{:,1};
time = datenum(yyyymmddHH) - 9/24;
timevec = datevec(time);

xticks = datenum(yyyy,1:12,1,0,0,0);

windspeed = []; winddirection = [];

windspeed = data{:,9};
winddirection = data{:,11};

winddegree = 90-winddirection;
winddegree(winddegree < 0) = winddegree(winddegree < 0) + 360;

uwind = -windspeed.*cosd(winddegree); % - sign for matching with current direction
vwind = -windspeed.*sind(winddegree);

%%%%%
% uwindmean = nanmean(uwind); uwindstd = nanstd(uwind);
% uwind(uwind > uwindmean + 3*uwindstd) = NaN;
% uwind(uwind < uwindmean - 3*uwindstd) = NaN;

timenum_unique = unique(floor(time));
clearvars uwind_daily vwind_daily
for ti = 1:length(timenum_unique)
    index = find(floor(time) == timenum_unique(ti));
    uwind_daily(ti) = nanmean(uwind(index));
    vwind_daily(ti) = nanmean(vwind(index));
end

figure; hold on; grid on
plot(timenum_unique, uwind_daily, 'k')

yp = (uwind_daily + abs(uwind_daily))/2;
yn = (uwind_daily - abs(uwind_daily))/2;

area(timenum_unique,yp, 'FaceColor', 'r');
area(timenum_unique,yn, 'FaceColor', 'b');

set(gca, 'xtick', xticks)
datetick('x', 'mm', 'keepticks')
xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),9,30)]);
%xlim([datenum(yyyy,4,1) datenum(yyyy,10,1)])
xlabel('Month')
ylabel('m/s')
ylim([-10 10])

title(['Zonal wind speed ', station, ' ', ystr])

set(gca, 'FontSize', 15)

saveas(gcf, ['uwind_daily_', station, '_', ystr, '.png'])


% figure; hold on; grid on
% uwind_movmean = movmean(uwind_daily, 14, 'omitnan', 'Endpoints', 'fill');
% plot(timenum_unique, uwind_movmean, 'k')
% 
% yp = (uwind_movmean + abs(uwind_movmean))/2;
% yn = (uwind_movmean - abs(uwind_movmean))/2;
% 
% area(timenum_unique,yp, 'FaceColor', 'r');
% area(timenum_unique,yn, 'FaceColor', 'b');
% 
% set(gca, 'xtick', xticks)
% datetick('x', 'mm', 'keepticks')
% xlim([datenum(yyyy,4,1) datenum(yyyy,10,1)])
% xlabel('Month')
% ylabel('m/s')
% ylim([-10 10])
% 
% title(['Zonal wind speed ', station, ' ', ystr])
% 
% set(gca, 'FontSize', 15)
% 
% saveas(gcf, ['uwind_14d_movmean_', station, '_', ystr, '.png'])

load([ystr, '_ERA5_uwind_GM.mat'])
timenum_ERA5 = datenum(wind_time(1:end-9)/24 + datenum(1900,1,1));

ERA5timenum_unique = unique(floor(timenum_ERA5));
clearvars ERA_uwind_daily
for ti = 1:length(ERA5timenum_unique)
    index = find(floor(timenum_ERA5) == ERA5timenum_unique(ti));
    ERA5_uwind_daily(ti) = nanmean(uwind_hourly(index));
end
dfdf
figure; hold on; grid on
p1 = plot(timenum_unique, uwind_daily, 'k', 'LineWidth', 2);
p2 = plot(ERA5timenum_unique, ERA5_uwind_daily, 'r', 'LineWidth', 2);

set(gca, 'xtick', xticks)
datetick('x', 'mm', 'keepticks')
xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),9,30)]);
%xlim([datenum(yyyy,4,1) datenum(yyyy,10,1)])
xlabel('Month')
ylabel('m/s')
ylim([-10 10])

l = legend('Buoy', 'ERA5');

title(['Zonal wind speed ', station, ' Buoy vs ERA5 ', ystr])

set(gca, 'FontSize', 15)

saveas(gcf, ['uwind_daily_', station, '_Buoy_vs_ERA5_', ystr, '.png'])

end