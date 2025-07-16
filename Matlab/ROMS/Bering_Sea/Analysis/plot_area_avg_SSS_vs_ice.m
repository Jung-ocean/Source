%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS area averaged SSS versus ice
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022;
ystr = num2str(yyyy);

region_salt = 'Koryak_coast';
filepath_salt = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Koryak_coast_common/';
filename_salt = 'SSS_ROMS_Koryak_coast_common_daily';
file_salt = [filepath_salt, filename_salt];
data_salt = load(file_salt);
timenum = data_salt.timenum;
SSS = data_salt.SSS;
index1 = find(timenum == datenum(yyyy,1,1));
index2 = find(timenum == datenum(yyyy,8,1));
timenum = timenum(index1:index2);
SSS = SSS(index1:index2);

region_ice = 'Gulf_of_Anadyr';
filepath_ice = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/';
filename_ice = ['ice_volume_Balance_GOA_', ystr, '_new.mat'];
file_ice = [filepath_ice, filename_ice];
data_ice = load(file_ice);
dt = 60*60*24;
ice = dt.*data_ice.dyn/1e9;
ice_cumsum = cumsum(ice);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
plot(timenum, SSS, 'k', 'LineWidth', 2);
xticks([datenum(yyyy,1:12,1)])
xlim([datenum(yyyy,1,1) datenum(yyyy,8,1)])
datetick('x', 'mmm', 'keepticks', 'keeplimits')
ylim([32 33.4])
ylabel('psu')

yyaxis right
plot(timenum, ice, 'b', 'LineWidth', 2);
plot(timenum, 0.*timenum, '-b')
ax = get(gca);
ax.YAxis(2).Color = 'b';
ylim([-15 15])
ylabel('km^3/day')

set(gca, 'FontSize', 15)

title(['SSS of ', replace(region_salt, '_', ' '), ' (black) vs Ice transport through the ', replace(region_ice, '_', ' '), ' (blue)'])

print(['area_avg_SSS_vs_ice_transport_', ystr], '-dpng')