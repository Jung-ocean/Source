%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SSS RMSE of NANOOS and WCOFS models using OISSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load rmse_SSS_OISSS.mat
mean_NANOOS = mean(rmse_NANOOS);
mean_WCOFS = mean(rmse_WCOFS);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, rmse_NANOOS, '.-k', 'LineWidth', 2, 'MarkerSize', 20);
pw = plot(timenum, rmse_WCOFS, '.-r', 'LineWidth', 2, 'MarkerSize', 20);

plot([datenum(2024,1,1) datenum(2024,1,1)], [0 3], '-k')
text(datenum(2023,11,15), 1.3, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 1.3, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([0 1.4])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('RMSE (psu)')

set(gca, 'FontSize', 12)

l = legend([pn, pw], ['NANOOS (mean = ', num2str(mean_NANOOS, '%.2f'), ')'], ['WCOFS (mean = ', num2str(mean_WCOFS, '%.2f'), ')']');
l.Location = 'NorthWest';
l.FontSize = 15;

title('SSS RMSE (OISSS 2.0)')
box on

print('rmse_SSS_OISSS', '-dpng')