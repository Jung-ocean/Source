clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
title_str = strrep(region, '_', ' ');

% ROMS sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/aice_ROMS_', region, '.mat'])
% ASI sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/Fi_ASI_', region, '.mat'])

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% ASI aice
subplot('Position',[.1,.15,.4,.75]); hold on; grid on

yyyy_all = 2012:2023;
yyyy_plot = 2019:2022;
num_mm = 7;

for yi = 1:length(yyyy_plot)
    yyyy = yyyy_plot(yi);
    index = find(yyyy_all == yyyy);
    p(yi) = plot(1:num_mm, Fi([1:num_mm] + (index-1)*num_mm), '-o', 'LineWidth', 2, 'Color', colors{yi});
end
xticks([1:num_mm])
xlim([0 8])
ylim([0 1])
xlabel('Month')
ylabel('Ice concentration')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
l.FontSize = 18;
title(['(a) ASI (', title_str, ')'])

% ROMS aice
subplot('Position',[.55,.15,.4,.75]); hold on; grid on

yyyy_plot = 2019:2022;
num_mm = 7;
for yi = 1:length(yyyy_plot)
    yyyy = yyyy_plot(yi);
    index = find(yyyy_all == yyyy);
    pmodel(yi) = plot(1:num_mm, aice([1:num_mm] + (yi-1)*num_mm), '-o', 'LineWidth', 2, 'Color', colors{yi});
end
xticks([1:num_mm])
xlim([0 8])
ylim([0 1])
xlabel('Month')
set(gca, 'FontSize', 15)
yticklabels('')
% l = legend(pmodel, '2019', '2020', '2021', '2022');
% l.Location = 'SouthWest';
title(['(b) ROMS (', title_str, ')'])

exportgraphics(gcf,'figure_cmp_aice_timeseries.png','Resolution',150) 