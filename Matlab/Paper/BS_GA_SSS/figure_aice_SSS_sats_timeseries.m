clear; clc; close all

yyyy_all = 2019:2022;
mm_start = 6;
dd_start = 15;
mm_end = 7;
dd_end = 31;
timenum_plot = [datenum(1,mm_start,dd_start):datenum(1,mm_end,dd_end)]';
xlimit = [timenum_plot(1) timenum_plot(end)];
colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};
FS = 12;

figure;
set(gcf, 'Position', [1 200 600 900])
t = tiledlayout(4,1);

% Sea ice
nexttile(1); hold on; grid on;
load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/aice/Gulf_of_Anadyr/Fi_ASI_Gulf_of_Anadyr_daily.mat');
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    
    index = find(timenum > datenum(yyyy,mm_start,dd_start)-1 & timenum < datenum(yyyy,mm_end,dd_end)+1);
    vari = 100*Fi(index);
    p(yi) = plot(timenum_plot, vari, 'Color', colors{yi}, 'LineWidth', 2);
end
xlim([xlimit])
ylim([0 20])
xticks(timenum_plot(1):10:timenum_plot(end));
xticklabels('')
ylabel('%')
set(gca,'FontSize', FS)
l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'NorthEast';
l.FontSize = 15;
title('(a) Sea ice concentration (ASI)', 'FontSize', 15)
box on

nexttile(2); hold on; grid on;
load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/SSS_SMAP_Gulf_of_Anadyr_common_daily');
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    
    index = find(timenum > datenum(yyyy,mm_start,dd_start)-1 & timenum < datenum(yyyy,mm_end,dd_end)+1);
    vari = SSS(index);
    p(yi) = plot(timenum_plot, vari, 'Color', colors{yi}, 'LineWidth', 2);
end
xlim([xlimit])
ylim([26 33])
xticks(timenum_plot(1):10:timenum_plot(end));
xticklabels('')
ylabel('psu')
set(gca,'FontSize', FS)
title('(b) SSS (SMAP)', 'FontSize', 15)
box on

nexttile(3); hold on; grid on;
load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/SSS_SMOS_BEC_Gulf_of_Anadyr_common_daily');
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    
    index = find(timenum > datenum(yyyy,mm_start,dd_start)-1 & timenum < datenum(yyyy,mm_end,dd_end)+1);
    vari = SSS(index);
    p(yi) = plot(timenum_plot, vari, 'Color', colors{yi}, 'LineWidth', 2);
end
xlim([xlimit])
ylim([30 33])
xticks(timenum_plot(1):10:timenum_plot(end));
xticklabels('')
ylabel('psu')
set(gca,'FontSize', FS)
title('(c) SSS (SMOS)', 'FontSize', 15)
box on

nexttile(4); hold on; grid on;
load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/SSS_ROMS_Gulf_of_Anadyr_common_daily');
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    
    index = find(timenum > datenum(yyyy,mm_start,dd_start)-1 & timenum < datenum(yyyy,mm_end,dd_end)+1);
    vari = SSS(index);
    index2 = find(isnan(vari) == 0);
    p(yi) = plot(timenum_plot(index2), vari(index2), '-', 'Color', colors{yi}, 'LineWidth', 2);
end
xlim([xlimit])
ylim([30 33])
xticks(timenum_plot(1):10:timenum_plot(end));
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
ylabel('psu')
set(gca,'FontSize', FS)
title('(d) SSS (ROMS)', 'FontSize', 15)
box on
% 
% 
% nexttile(4); hold on; grid on;
% load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/SSS_ROMS_Gulf_of_Anadyr_common_daily');
% % load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr/SSS_ROMS_Gulf_of_Anadyr_daily.mat')
% for yi = 1:length(yyyy_all)
%     yyyy = yyyy_all(yi);
%     
%     index = find(timenum > datenum(yyyy,mm_start,dd_start)-1 & timenum < datenum(yyyy,mm_end,dd_end)+1);
%     vari = SSS(index);
%     p(yi) = plot(timenum_plot, vari, 'Color', colors{yi}, 'LineWidth', 2);
% end
% xlim([xlimit])
% % ylim([30 33.5])
% ylim([27 34])
% xticks(timenum_plot(1):10:timenum_plot(end));
% datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
% % yticks([30:34])
% xlabel('Date')
% ylabel('psu')
% set(gca,'FontSize', FS)
% title('(d) SSS (ROMS)', 'FontSize', 15)

t.Padding = 'compact';
t.TileSpacing = 'tight';
ddd
exportgraphics(gcf,'figure_aice_SSS_sats_timeseries.tif','Resolution',300)