%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot current RMSE of NANOOS and WCOFS models using HF radar
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'u';
load(['rmse_surf_', vari_str, '_HFR.mat'])

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, vari_NANOOS_mean, '-k', 'LineWidth', 2);
pw = plot(timenum, vari_WCOFS_mean, '-r', 'LineWidth', 2);
po = plot(timenum, vari_obs_mean, '-g', 'LineWidth', 2);

plot([datenum(2024,1,1) datenum(2024,1,1)], [-100 100], '-k')
text(datenum(2023,11,15), 55, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 55, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([-60 60])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('cm/s')

set(gca, 'FontSize', 12)

l = legend([pn, pw, po], ...
    ['OSU ROMS (', ... 
    'bias = ', num2str(bias_NANOOS, '%.2f'), ' cm/s, ', ...
    'RMSE = ', num2str(rmse_NANOOS, '%.2f'), ' cm/s, ', ...
    'corr coef = ', num2str(corrcoef_NANOOS, '%.2f'), ')'], ...
    ['WCOFS (', ...
    'bias = ', num2str(bias_WCOFS, '%.2f'), ' cm/s, ', ...
    'RMSE = ', num2str(rmse_WCOFS, '%.2f'), ' cm/s, ', ...
    'corr coef = ', num2str(corrcoef_WCOFS, '%.2f'), ')'], ...
    'Observation');
l.Location = 'SouthEast';
l.FontSize = 15;

if strcmp(vari_str, 'u')
    title('Surface zonal current (daily)')
else
    title('Surface meridional current (daily)')
end
box on

print(['timeseries_surf_', vari_str, '_HFR'], '-dpng')