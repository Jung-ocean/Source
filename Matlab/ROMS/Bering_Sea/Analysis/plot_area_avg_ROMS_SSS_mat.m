%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS area-averaged SSS using .mat file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast_common';
title_str = strrep(region, '_', ' ');
load(['SSS_ROMS_', region, '.mat'])

yyyy_all = 2019:2023;
num_mm = 12;
plot_mm = 12;

SSS_surf_reshape = reshape(SSS_surf, [num_mm, length(yyyy_all)]);
SSS_surf_climate = mean(SSS_surf_reshape, 2);
SSS_surf_climate = SSS_surf_climate(1:plot_mm);

S_volavg_reshape = reshape(S_volavg, [num_mm, length(yyyy_all)]);
S_volavg_climate = mean(S_volavg_reshape, 2);
S_volavg_climate = S_volavg_climate(1:plot_mm);

% Area averaged SSS
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, SSS_surf((i-1)*num_mm + [1:plot_mm]), '-o', 'LineWidth', 2);
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([28 34])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['Area-averaged SSS (', title_str, ')'])

print(['area_avg_SSS_', region], '-dpng')

% Volume averaged SSS
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, S_volavg((i-1)*num_mm + [1:plot_mm]), '-o', 'LineWidth', 2);
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([28 34])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['Volume-averaged salinity (', title_str, ')'])

print(['volume_avg_S_', region], '-dpng')

% Area averaged SSSA
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, SSS_surf((i-1)*num_mm + [1:plot_mm]) - SSS_surf_climate, '-o', 'LineWidth', 2);
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([-1 1])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['Area-averaged SSS anomaly (', title_str, ')'])

print(['area_avg_SSSA_', region], '-dpng')

% Volume averaged SSSA
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, S_volavg((i-1)*num_mm + [1:plot_mm])  - S_volavg_climate, '-o', 'LineWidth', 2);
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([-1 1])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['Volume-averaged salinity anomaly (', title_str, ')'])

print(['volume_avg_SA_', region], '-dpng')