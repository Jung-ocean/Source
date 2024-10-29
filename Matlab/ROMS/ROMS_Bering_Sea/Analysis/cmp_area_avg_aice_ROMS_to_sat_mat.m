%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged aice to satellite using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
title_str = strrep(region, '_', ' ');

% ROMS sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/aice_ROMS_', region, '.mat'])
% ASI sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/Fi_ASI_', region, '.mat'])

colors = {'0 0.4471 0.7412', '0.8510 0.3255 0.0980', '0.9294 0.6941 0.1255', '0.4941 0.1843 0.5569'};

% ASI aice
yyyy_all = 2012:2023;
yyyy_plot = 2019:2022;
num_mm = 7;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for yi = 1:length(yyyy_plot)
    yyyy = yyyy_plot(yi);
    index = find(yyyy_all == yyyy);
    p(yi) = plot(1:num_mm, Fi([1:num_mm] + (index-1)*num_mm), '-o', 'LineWidth', 2, 'Color', colors{yi});
end
xticks([1:num_mm])
xlim([0 8])
ylim([0 1])
xlabel('Month')
ylabel('aice')
set(gca, 'FontSize', 15)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['ASI sea ice concentration in the ', title_str])

print(['ASI_area_avg_aice_', region], '-dpng')

% ROMS aice
yyyy_plot = 2019:2022;
num_mm = 7;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for yi = 1:length(yyyy_plot)
    yyyy = yyyy_plot(yi);
    index = find(yyyy_all == yyyy);
    pmodel(yi) = plot(1:num_mm, aice([1:num_mm] + (yi-1)*num_mm), '-o', 'LineWidth', 2, 'Color', colors{yi});
end
xticks([1:num_mm])
xlim([0 8])
ylim([0 1])
xlabel('Month')
ylabel('aice')
set(gca, 'FontSize', 15)
l = legend(pmodel, '2019', '2020', '2021', '2022');
l.Location = 'SouthWest';
title(['ROMS sea ice concentration in the ', title_str])

print(['ROMS_area_avg_aice_', region], '-dpng')
