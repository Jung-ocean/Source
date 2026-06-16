clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr';
title_str = strrep(region, '_', ' ');

% ASI sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/aice/', region, '/Fi_ASI_', region, '_daily.mat'])

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% ASI aice
pobs = plot(timenum, Fi*100, '-r', 'LineWidth', 2);

% ROMS sea ice concentration
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/aice/', region, '/aice_ROMS_', region, '_daily.mat'])
% ROMS aice
timenum = timenum';
aice = (aice*100)';
pmodel = plot(timenum, aice, '-k', 'LineWidth', 2);

xticks([datenum(2019,[1 5], 1), datenum(2020,[1 5], 1), datenum(2021,[1 5], 1), datenum(2022,[1 5], 1)])
xlim([datenum(2019,1,1)-1 datenum(2022,12,31)+1])
ylim([0 100])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylabel('Sea ice concentration (%)')
set(gca, 'FontSize', 12)
% set(gca,'XTickLabelRotation',30)

% plot([datenum(2019,1,1) datenum(2019,1,1)], [0 100], '-k', 'LineWidth', .5)
plot([datenum(2019,5,1) datenum(2019,5,1)], [0 100], '--k', 'LineWidth', 1)

idx_start = find(timenum >= datenum(2019,5,1),1);
idx_end = find(aice(idx_start:end) < 1e-3,1) + idx_start -1;
% shading
x_fill = [timenum(idx_start:idx_end) ...
          fliplr(timenum(idx_start:idx_end))];
y_fill = [aice(idx_start:idx_end) ...
          zeros(1,length(idx_start:idx_end))];
fill(x_fill, y_fill, 'k', 'FaceAlpha',0.3, 'EdgeColor','none');

% plot([datenum(2020,1,1) datenum(2020,1,1)], [0 100], '-k', 'LineWidth', .5)
plot([datenum(2020,5,1) datenum(2020,5,1)], [0 100], '--k', 'LineWidth', 1)

idx_start = find(timenum >= datenum(2020,5,1),1);
idx_end = find(aice(idx_start:end) < 1e-3,1) + idx_start -1;
% shading
x_fill = [timenum(idx_start:idx_end) ...
          fliplr(timenum(idx_start:idx_end))];
y_fill = [aice(idx_start:idx_end) ...
          zeros(1,length(idx_start:idx_end))];
fill(x_fill, y_fill, 'k', 'FaceAlpha',0.3, 'EdgeColor','none');

% plot([datenum(2021,1,1) datenum(2021,1,1)], [0 100], '-k', 'LineWidth', .5)
plot([datenum(2021,5,1) datenum(2021,5,1)], [0 100], '--k', 'LineWidth', 1)

idx_start = find(timenum >= datenum(2021,5,1),1);
idx_end = find(aice(idx_start:end) < 1e-3,1) + idx_start -1;
% shading
x_fill = [timenum(idx_start:idx_end) ...
          fliplr(timenum(idx_start:idx_end))];
y_fill = [aice(idx_start:idx_end) ...
          zeros(1,length(idx_start:idx_end))];
fill(x_fill, y_fill, 'k', 'FaceAlpha',0.3, 'EdgeColor','none');

% plot([datenum(2022,1,1) datenum(2022,1,1)], [0 100], '-k', 'LineWidth', .5)
plot([datenum(2022,5,1) datenum(2022,5,1)], [0 100], '--k', 'LineWidth', 1)

idx_start = find(timenum >= datenum(2022,5,1),1);
idx_end = find(aice(idx_start:end) < 1e-3,1) + idx_start -1;
% shading
x_fill = [timenum(idx_start:idx_end) ...
          fliplr(timenum(idx_start:idx_end))];
y_fill = [aice(idx_start:idx_end) ...
          zeros(1,length(idx_start:idx_end))];
fill(x_fill, y_fill, 'k', 'FaceAlpha',0.3, 'EdgeColor','none');

l = legend([pobs pmodel], 'ASI', 'ROMS');
l.Location = 'NorthEast';
l.FontSize = 18;

title('Sea ice concentration in the Gulf of Anadyr', 'FontSize', 15)
box on
asdf
% print('cmp_aice_timeseries_overlaid', '-dpng')
exportgraphics(gcf,'cmp_aice_timeseries_overlaid.tif','Resolution',300) 