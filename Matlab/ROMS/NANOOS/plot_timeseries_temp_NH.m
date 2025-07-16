%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot temp RMSE of NANOOS and WCOFS models using NH line
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

si = 1;

stations = {'NH05', 'NH25'};
depths = [-50 -150];
total_depths = [60 296];
lats = [44.652 44.652];
lons = [-124.177 -124.650];

station = stations{si};
depth = depths(si);
total_depth = total_depths(si);
lat_obs = lats(si);
lon_obs = lons(si);

vari_str = 'temp';
load(['rmse_', vari_str, '_', station, '.mat'])

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, vari_NANOOS, '.-k', 'LineWidth', 2, 'MarkerSize', 15);
pw = plot(timenum, vari_WCOFS, '.-r', 'LineWidth', 2, 'MarkerSize', 15);
po = plot(timenum, vari_obs, '.-g', 'LineWidth', 2, 'MarkerSize', 15);

plot([datenum(2024,1,1) datenum(2024,1,1)], [-100 100], '-k')
text(datenum(2023,11,15), 13.5, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 13.5, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([2 14])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('^oC')

set(gca, 'FontSize', 12)

l = legend([pn, pw, po], ...
    ['OSU ROMS (', ... 
    'bias = ', num2str(bias_NANOOS, '%.2f'), ' ^oC, ', ...
    'RMSE = ', num2str(rmse_NANOOS, '%.2f'), ' ^oC, ', ...
    'corr coef = ', num2str(corrcoef_NANOOS, '%.2f'), ')'], ...
    ['WCOFS (', ...
    'bias = ', num2str(bias_WCOFS, '%.2f'), ' ^oC, ', ...
    'RMSE = ', num2str(rmse_WCOFS, '%.2f'), ' ^oC, ', ...
    'corr coef = ', num2str(corrcoef_WCOFS, '%.2f'), ')'], ...
    'Observation');
l.Location = 'SouthEast';
l.FontSize = 15;

title(['Temperature at ', station, ' (', num2str(-depth), ' m)'])
box on

print(['timeseries_temp_', station], '-dpng')