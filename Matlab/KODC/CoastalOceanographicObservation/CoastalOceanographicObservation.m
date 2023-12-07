clear; clc; close all

station = '제주';
year_target = 2004; yts = num2str(year_target);

filepath = 'D:\Data\Ocean\연안정지관측자료\';
filename = ['연안정지_', station, '.xls'];
file = [filepath, filename];

[num, txt, raw] = xlsread(file);

sst = txt(3:end,4); sst_flag = txt(3:end, 5);
airT = txt(3:end,6); airT_flag = txt(3:end, 7);

date = txt(3:end,3);
yyyymmdd = datenum(date, 'yyyymmdd');

sst_num = zeros(size(sst));
airT_num = zeros(size(airT));
for i = 1:length(sst)
    try
        sst_num(i) = str2num(sst{i});
    catch
        sst_num(i) = nan;
    end
    
    if ~strcmp(sst_flag{i}, '1')
        sst_num(i) = nan;
    end
    
    try
        airT_num(i) = str2num(airT{i});
    catch
        airT_num(i) = nan;
    end
    
    if ~strcmp(airT_flag{i}, '1')
        airT_num(i) = nan;
    end
end

datevec_yyyymmdd = datevec(yyyymmdd);

index = find(datevec_yyyymmdd(:,1) == year_target);
yyyymmdd = yyyymmdd(1:index(end));
airT_num = airT_num(1:index(end));
sst_num = sst_num(1:index(end));

%==========================================================================
figure(1); set(gcf, 'Position', [1 1 1854 1002]);
subplot(2,1,1); hold on
plot(yyyymmdd, airT_num, '.')

ylim([-10 35])
xticks(yyyymmdd(1):365:yyyymmdd(end))
datetick('x', 'yy')
xlabel('Year'); ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)
title(['기온 연안정지 ', station], 'FontSize', 20)
grid on

index = find(isnan(airT_num) ~= 1);
x = yyyymmdd(index); y = airT_num(index);

datevec_x = datevec(x);

airT_seasonal = zeros(366,1);
y_wo_seasonal = y;
for di = 1:366
    datevec_seasonal = datevec(di);
    mm_seasonal = datevec_seasonal(:,2);
    dd_seasonal = datevec_seasonal(:,3);
    
    index = find(datevec_x(:,2) == mm_seasonal & datevec_x(:,3) == dd_seasonal);
    airT_seasonal(di) = nanmean(y(index));
    
    y_wo_seasonal(index) = y(index) - airT_seasonal(di);
end

[p,s] = polyfit(x, y_wo_seasonal, 1);
y1 = polyval(p,x);

figure(2); set(gcf, 'Position', [1 1 1854 1002]);
subplot(2,1,1); hold on
plot(x, y_wo_seasonal, '.')
h1 = plot(x, y1, '-k', 'LineWidth', 2);

ylim([-15 15])
xticks(yyyymmdd(1):365:yyyymmdd(end))
datetick('x', 'yy')
xlabel('Year'); ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)
title(['기온 연안정지 ', station], 'FontSize', 20)
grid on

l = legend(h1, sprintf('%f', p(1)), 'Location', 'SouthWest');
l.FontSize = 20;
%==========================================================================
figure(1)
subplot(2,1,2); hold on
plot(yyyymmdd, sst_num, '.')

index = find(isnan(sst_num) ~= 1);
x = yyyymmdd(index); y = sst_num(index);

datevec_x = datevec(x);

ylim([-10 35])
xticks(yyyymmdd(1):365:yyyymmdd(end))
datetick('x', 'yy')
xlabel('Year'); ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)
title(['수온 연안정지 ', station], 'FontSize', 20)
grid on

sst_seasonal = zeros(366,1);
y_wo_seasonal = y;
for di = 1:366
    datevec_seasonal = datevec(di);
    mm_seasonal = datevec_seasonal(:,2);
    dd_seasonal = datevec_seasonal(:,3);
    
    index = find(datevec_x(:,2) == mm_seasonal & datevec_x(:,3) == dd_seasonal);
    sst_seasonal(di) = nanmean(y(index));
    
    y_wo_seasonal(index) = y(index) - sst_seasonal(di);
end

[p,s] = polyfit(x, y_wo_seasonal, 1);
y1 = polyval(p,x);

figure(2);
subplot(2,1,2); hold on
plot(x, y_wo_seasonal, '.')
h1 = plot(x, y1, '-k', 'LineWidth', 2);

ylim([-15 15])
xticks(yyyymmdd(1):365:yyyymmdd(end))
datetick('x', 'yy')
xlabel('Year'); ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)
title(['수온 연안정지 ', station], 'FontSize', 20)
grid on

l = legend(h1, sprintf('%f', p(1)), 'Location', 'SouthWest');
l.FontSize = 20;

figure(1)
saveas(gcf, ['연안정지_', station, '_', yts, '.png'])

figure(2)
saveas(gcf, ['연안정지_', station, '_trend_', yts, '.png'])