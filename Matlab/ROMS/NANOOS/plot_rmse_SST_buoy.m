%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SST RMSE of NANOOS and WCOFS models using NDBC buoy
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load rmse_SST_buoy.mat
mean_NANOOS = mean(rmse_NANOOS);
mean_WCOFS = mean(rmse_WCOFS);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, rmse_NANOOS, '.-k', 'LineWidth', 2, 'MarkerSize', 20);
pw = plot(timenum, rmse_WCOFS, '.-r', 'LineWidth', 2, 'MarkerSize', 20);

plot([datenum(2024,1,1) datenum(2024,1,1)], [0 3], '-k')
text(datenum(2023,11,15), 1.4, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 1.4, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([0 1.5])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('RMSE (^oC)')

set(gca, 'FontSize', 12)

l = legend([pn, pw], ['NANOOS (mean = ', num2str(mean_NANOOS, '%.2f'), ')'], ['WCOFS (mean = ', num2str(mean_WCOFS, '%.2f'), ')']');
l.Location = 'NorthWest';
l.FontSize = 15;

title('SST RMSE (buoy)')
box on

print('rmse_SST_buoy', '-dpng')

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
plot(timenum, num_data, '-k', 'LineWidth', 2)
xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([0 17]);

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm')

set(gca, 'FontSize', 12)

title('# of data point (total = 17)')
box on

print('number_data_point_rmse_SST_buoy', '-dpng')