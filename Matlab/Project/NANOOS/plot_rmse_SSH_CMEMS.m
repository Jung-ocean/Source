%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SSH RMSE of NANOOS and WCOFS models using CMEMS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load rmse_SSH_CMEMS.mat
mean_NANOOS = mean(rmse_NANOOS, 'omitnan');
mean_WCOFS = mean(rmse_WCOFS, 'omitnan');

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, rmse_NANOOS, '.-k', 'LineWidth', 2, 'MarkerSize', 20);
pw = plot(timenum, rmse_WCOFS, '.-r', 'LineWidth', 2, 'MarkerSize', 20);

plot([datenum(2024,1,1) datenum(2024,1,1)], [0 8], '-k')
text(datenum(2023,11,15), 6.5, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 6.5, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([0 7])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('RMSE (cm)')

set(gca, 'FontSize', 12)

l = legend([pn, pw], ['NANOOS (mean = ', num2str(mean_NANOOS, '%.2f'), ')'], ['WCOFS (mean = ', num2str(mean_WCOFS, '%.2f'), ')']');
l.Location = 'SouthWest';
l.FontSize = 15;

title('SSH RMSE (CMEMS all sat)')
box on

print('rmse_SSH_CMEMS', '-dpng')