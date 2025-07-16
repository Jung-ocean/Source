%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare sea ice concentration time series between model and satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

si = 3;

datenum_start = datenum(2021,1,1);
datenum_end = datenum(2023,12,31);

stations = {'bs2', 'bs4', 'bs5', 'bs8'};
names = {'M2', 'M4', 'M5', 'M8'};

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

load Fi_ASI_M5_50km_daily.mat
psat = plot(timenum, Fi, 'r', 'LineWidth', 2);

load aice_ROMS_M5_50km_daily.mat
pmodel = plot(timenum, aice, 'k', 'LineWidth', 2);

xlim([datenum_start-1 datenum_end+1])
xticks(datenum(2019:2023,1,1))
datetick('x', 'yyyy', 'keeplimits', 'keeplimits')
ylabel('Sea ice concentration')

set(gca, 'FontSize', 12)

l = legend([psat, pmodel], 'ASI', 'ROMS');
l.Location = 'NorthWest';
l.NumColumns = 1;
l.FontSize = 15;

title(['Sea ice concentration at ', names{si}, ' (50 km x 50 km)'])

print(['cmp_aice_timeseries_', names{si}], '-dpng')