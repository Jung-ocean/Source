clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
title_str = strrep(region, '_', ' ');

% ROMS sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/aice_ROMS_', region, '_daily.mat'])
% ASI sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/Fi_ASI_', region, '_daily.mat'])

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% ASI aice
pobs = plot(timenum, Fi, '-r', 'LineWidth', 2);

% ROMS aice
pmodel = plot(timenum, aice, '-k', 'LineWidth', 2);

% plot([datenum(2019,5,1) datenum(2019,5,1)], [0 1], '-k', 'LineWidth', 1)
% plot([datenum(2020,5,1) datenum(2020,5,1)], [0 1], '-k', 'LineWidth', 1)
% plot([datenum(2021,5,1) datenum(2021,5,1)], [0 1], '-k', 'LineWidth', 1)
% plot([datenum(2022,5,1) datenum(2022,5,1)], [0 1], '-k', 'LineWidth', 1)

xticks([datenum(2019,[1 5], 1), datenum(2020,[1 5], 1), datenum(2021,[1 5], 1), datenum(2022,[1 5], 1)])
xlim([datenum(2019,1,1)-1 datenum(2022,12,31)+1])
ylim([0 1])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('Sea ice concentration')
set(gca, 'FontSize', 15)
set(gca,'XTickLabelRotation',30)

l = legend([pobs pmodel], 'ASI', 'ROMS');
l.Location = 'NorthEast';
l.FontSize = 18;

title('Sea ice concentration in the Gulf of Anadyr')
box on

exportgraphics(gcf,'figure_cmp_aice_timeseries_overlaid.png','Resolution',150) 