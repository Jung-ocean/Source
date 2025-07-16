clear; clc; close all

load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr/SSS_ROMS_Gulf_of_Anadyr.mat'])

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};

yyyy_all = 2019:2022;
num_mm = 12;
plot_mm = 12;

SSS_surf_reshape = reshape(SSS_surf, [num_mm, length(yyyy_all)]);
SSS_surf_climate = mean(SSS_surf_reshape, 2);
SSS_surf_climate = SSS_surf_climate(1:plot_mm);

S_volavg_reshape = reshape(S_volavg, [num_mm, length(yyyy_all)]);
S_volavg_climate = mean(S_volavg_reshape, 2);
S_volavg_climate = S_volavg_climate(1:plot_mm);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% Area averaged SSSA
subplot('Position',[.1,.15,.4,.75]); hold on; grid on

for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, SSS_surf((i-1)*num_mm + [1:plot_mm]) - SSS_surf_climate, '-o', 'LineWidth', 2, 'Color', colors{i});
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([-1 1])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
l.FontSize = 15;
title(['(a) Area-averaged SSS anomaly (Gulf of Anadyr)'], 'FontSize', 13)
box on

% Volume averaged SSSA
subplot('Position',[.52,.15,.4,.75]); hold on; grid on

for i = 1:length(yyyy_all)
    p(i) = plot(1:plot_mm, S_volavg((i-1)*num_mm + [1:plot_mm])  - S_volavg_climate, '-o', 'LineWidth', 2, 'Color', colors{i});
end
xticks([1:plot_mm])
xlim([0 plot_mm+1])
ylim([-1 1])
xlabel('Month')
% ylabel('psu')
set(gca, 'FontSize', 15)
yticklabels('')
title(['(b) Volume-averaged salinity anomaly (Gulf of Anadyr)'], 'FontSize', 13)
box on
dd
exportgraphics(gcf,'figure_area_vol_avg_SA_timeseries.png','Resolution',150) 