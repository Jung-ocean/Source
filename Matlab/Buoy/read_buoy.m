clear; clc

yyyy_all = 2019:2019;

stations = {'남해동부', '대한해협', '통영', '생일도', '여수항', '완도항', '광양항', '감천항', '부산항'};

for si = 4:4%length(stations)
    station = stations{si};

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

switch station
    case '남해동부'
        filecode = 'TW_KG_KG_0025';
    case '대한해협'
        filecode = 'TW_KG_KG_0024';
    case '통영'
        filecode = 'TW_TW_TONGYEONG';
    case '생일도'
        filecode = 'TW_TW_SAENGIL';
    case '여수항'
        filecode = 'TW_TW_YEOSU';
    case '완도항'
        filecode = 'TW_TW_WANDO';
    case '광양항'
        filecode = 'TW_TW_GWANGYANG';
    case '감천항'
        filecode = 'TW_TW_GAMCHEON';
    case '부산항'
        filecode = 'TW_TW_BUSAN';
end

filepath = 'D:\Data\Ocean\Buoy\해양관측부이/';
filename = ['data_', ystr, '_', filecode, '_', ystr, '_KR'];
file = [filepath, filename];

data = read_buoy_function(file);
yyyymmddHH = data{:,1};
time = datenum(yyyymmddHH);
timevec = datevec(yyyymmddHH);

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
umean = nanmean(u); ustd = nanstd(u);
u(u > umean + 3*ustd) = NaN;
u(u < umean - 3*ustd) = NaN;

figure; hold on; grid on
u_movmean = movmean(u, 48*14, 'omitnan', 'Endpoints', 'fill');
plot(time, u_movmean, 'k')
yp = (u_movmean + abs(u_movmean))/2;
yn = (u_movmean - abs(u_movmean))/2;

area(time,yp, 'FaceColor', 'r');
area(time,yn, 'FaceColor', 'b');

set(gca, 'xtick', xticks)
datetick('x', 'mm', 'keepticks')
xlabel('Month')
ylabel('cm/s')
ylim([-20 20])

title(['Zonal velocity ', station, ' ', ystr])

set(gca, 'FontSize', 15)

saveas(gcf, ['u_', station, '_', ystr, '.png'])
%%%%%
% figure; hold on; grid on
% plot(time, uwind)
% datetick('x')
% ylabel('m/s')
% 
% title(['Zonal wind speed ', station, ' ', ystr])
%%%%%
uwindmean = nanmean(uwind); uwindstd = nanstd(uwind);
uwind(uwind > uwindmean + 3*uwindstd) = NaN;
uwind(uwind < uwindmean - 3*uwindstd) = NaN;

% wind plot
% % figure; hold on; grid on
% % % uwind_movmean = movmean(uwind, 24*14, 'omitnan', 'Endpoints', 'fill');
% % uwind_movmean = uwind;
% % plot(time, uwind_movmean, 'k')
% % 
% % yp = (uwind_movmean + abs(uwind_movmean))/2;
% % yn = (uwind_movmean - abs(uwind_movmean))/2;
% % 
% % area(time,yp, 'FaceColor', 'r');
% % area(time,yn, 'FaceColor', 'b');
% % 
% % set(gca, 'xtick', xticks)
% % datetick('x', 'mm', 'keepticks')
% % xlim([datenum(yyyy,4,1) datenum(yyyy,10,1)])
% % xlabel('Month')
% % ylabel('m/s')
% % ylim([-10 10])
% % 
% % title(['Zonal wind speed ', station, ' ', ystr])
% % 
% % set(gca, 'FontSize', 15)
% % 
% % saveas(gcf, ['uwind_', station, '_', ystr, '.png'])

end
end