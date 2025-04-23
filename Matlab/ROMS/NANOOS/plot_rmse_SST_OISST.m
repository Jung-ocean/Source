%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SST RMSE of NANOOS and WCOFS models using OISST
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load rmse_SST_OISST.mat
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

title('SST RMSE (OISST 2.1)')
box on

print('rmse_SST_OISST', '-dpng')