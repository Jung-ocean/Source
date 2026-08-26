%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2024;
ystr = num2str(yyyy);

vari_str = 'uv';

load(['metrics_', vari_str, '_HFR_', ystr, '.mat'])

FS = 15;

figure;
set(gcf, 'Position', [1 200 900 800])
t = tiledlayout(2,1);
t.Padding = 'compact';
t.TileSpacing = 'tight';

nexttile(1); hold on; grid on
plot(timenum, aarmse_CR_NANOOS, '-k', 'LineWidth', 2);
plot(timenum, aarmse_CR_WCOFS, '-r', 'LineWidth', 2);
xlim([timenum(1)-1 timenum(end)+1])
ylim([5 35])
xticks([datenum(2024,1:12,1)])
xticklabels('')
ylabel('RMSE (cm/s)')
set(gca, 'FontSize', FS)
title('Columbia River', 'FontSize', 20)

nexttile(2); hold on; grid on
pn = plot(timenum, aarmse_HB_NANOOS, '-k', 'LineWidth', 2);
pw = plot(timenum, aarmse_HB_WCOFS, '-r', 'LineWidth', 2);
xlim([timenum(1)-1 timenum(end)+1])
ylim([5 35])
xticks([datenum(2024,1:12,1)])
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits');
xlabel('Date')
ylabel('RMSE (cm/s)')
set(gca, 'FontSize', FS)
title('Heceta Bank', 'FontSize', 20)

l = legend([pn, pw], 'OSU ROMS', 'WCOFS');
l.Location = 'NorthWest';
l.FontSize = FS;

print(['timeseries_rmse_HFR_', ystr], '-dpng')