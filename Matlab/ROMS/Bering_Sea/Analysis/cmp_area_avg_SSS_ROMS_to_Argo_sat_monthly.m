%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SSS through area-averaged to Argo and Satellites monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Cape_Olyutor';

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1500 500])

% ARGO BOA
load(['SSS_ARGO_BOA_', region, '.mat'])
pargo = plot(timenum, SSS, '-', 'LineWidth', 2);

% % OISSS
% load('SSS_OISSS_Cape_Olyutor.mat')
% poisss = plot(timenum, SSS, '-o');

% ROMS
load(['SSS_ROMS_Dsm4_mk2_', region, '.mat'])
proms = plot(timenum, SSS_surf, '-k', 'LineWidth', 2);

% RSS SMAP
load(['SSS_SMAP_', region, '.mat'])
psmap = plot(timenum, SSS, '-', 'LineWidth', 2);

% CEC SMOS
load(['SSS_SMOS_', region, '.mat'])
psmos = plot(timenum, SSS, '-', 'LineWidth', 2);

% % BEC SMOS
% load('SSS_SMOS_BEC_Cape_Olyutor.mat')
% psmos_bec = plot(timenum, SSS, '-o');

xticks(datenum(2010:2025,1,1))
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylim([32.1 34.3])
ylabel('psu')
set(gca, 'FontSize', 12)

l = legend([pargo, proms, psmap, psmos], 'ARGO BOA', 'ROMS', 'RSS SMPA v6.0', 'CEC SMOS v10');
l.Location = 'NorthWest';
l.FontSize = 15;

title(['Area-averaged SSS (', replace(region, '_', ' '), ')'])

print(['cmp_area_avg_SSS_', region], '-dpng')

