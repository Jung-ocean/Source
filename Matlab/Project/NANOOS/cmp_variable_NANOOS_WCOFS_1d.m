%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'swrad';
location = 'WA_shelf';

datenum_start = datenum(2025,2,22);
datenum_end = datenum(2025,2,28);

switch location
    case 'WA_shelf'
        lat_target = 46.99;
        lon_target = -124.57;
        file_obs = '/data/jungjih/Observations/NANOOS/OOI_CE07SHSM/OOI_CE07SHSM-A1_SolarRad-excel.csv';
        data = readtable(file_obs);
        time1 = table2array(data(:,1));
        time2 = cell2mat(table2cell(data(:,2)));
        time_obs = [char(time1) time2];
        timenum_obs = datenum(time_obs, 'yyyy-mm-ddHH:MM') + 8/24; % PST to UTC
        vari_obs = table2array(data(:,5));

        title_str = replace(location, '_', ' ');
end

% Map
figure; hold on; grid on;
plot_map('US_west', 'mercator', 'l');
set(gcf, 'Position', [1 200 500 800])
g = grd('NANOOS');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');
cl = clabelm(cs, h, 'LabelSpacing', 500);
set(cl, 'BackgroundColor', 'none')
plotm(lat_target, lon_target, '.r', 'MarkerSize', 25)
print(['location_', vari_str, '_', location], '-dpng')

% Comparison
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])

po = plot(timenum_obs, vari_obs, '-g', 'LineWidth', 2);

[tN, vN] = load_NANOOS_2d(vari_str, datenum_start, datenum_end, lat_target, lon_target);
pN = plot(tN,vN, '-k', 'LineWidth', 2);

[tW, vW] = load_WCOFS_2d(vari_str, datenum_start, datenum_end, lat_target, lon_target);
pW = plot(tW,vW, '-b', 'LineWidth', 2);

xticks([datenum_start:1:datenum_end])
xlim([datenum_start-1 datenum_end+1])

datetick('x', 'mmm dd HH:MM', 'keepticks', 'keeplimits')
ylabel('W/m^2')

set(gca, 'FontSize', 12)

l = legend([po, pN, pW], 'Observation', 'NANOOS', 'WCOFS');
l.Location = 'NorthWest';
l.FontSize = 15;

title([vari_str '(', title_str, ')'])

print(['cmp_', vari_str, '_', location], '-dpng')