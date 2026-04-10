%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SSS through area-averaged to Argo and Satellites climate
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Cape_Olyutor';
yyyy_all = 2019:2023;
ystr_start = num2str(yyyy_all(1));
ystr_end = num2str(yyyy_all(end));
mm_all = 1:12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])

% ARGO BOA
load(['SSS_ARGO_BOA_', region, '.mat'])
timevec = datevec(timenum);
SSS_mean = NaN(12,1);
SSS_std = NaN(12,1);
for mi = 1:length(mm_all)
    mm = mm_all(mi);
    index = find(ismember(timevec(:,1), yyyy_all) & ismember(timevec(:,2), mm));
    SSS_mean(mi) = mean(SSS(index));
    SSS_std(mi) = std(SSS(index));
end
pargo = errorbar(1:12, SSS_mean, SSS_std, 'LineWidth', 2);

% % OISSS
% load('SSS_OISSS_Cape_Olyutor.mat')
% poisss = plot(timenum, SSS, '-o');

% ROMS
load(['SSS_ROMS_Dsm4_mk2_', region, '.mat'])
timevec = datevec(timenum);
SSS_mean = NaN(12,1);
SSS_std = NaN(12,1);
for mi = 1:length(mm_all)
    mm = mm_all(mi);
    index = find(ismember(timevec(:,1), yyyy_all) & ismember(timevec(:,2), mm));
    SSS_mean(mi) = mean(SSS_surf(index));
    SSS_std(mi) = std(SSS_surf(index));
end
proms = errorbar(1:12, SSS_mean, SSS_std, '-k', 'LineWidth', 2);

% RSS SMAP
load(['SSS_SMAP_', region, '.mat'])
timevec = datevec(timenum);
SSS_mean = NaN(12,1);
SSS_std = NaN(12,1);
for mi = 1:length(mm_all)
    mm = mm_all(mi);
    index = find(ismember(timevec(:,1), yyyy_all) & ismember(timevec(:,2), mm));
    SSS_mean(mi) = mean(SSS(index));
    SSS_std(mi) = std(SSS(index));
end
psmap = errorbar(1:12, SSS_mean, SSS_std, 'LineWidth', 2);

% CEC SMOS
load(['SSS_SMOS_', region, '.mat'])
timevec = datevec(timenum);
SSS_mean = NaN(12,1);
SSS_std = NaN(12,1);
for mi = 1:length(mm_all)
    mm = mm_all(mi);
    index = find(ismember(timevec(:,1), yyyy_all) & ismember(timevec(:,2), mm));
    SSS_mean(mi) = mean(SSS(index));
    SSS_std(mi) = std(SSS(index));
end
psmos = errorbar(1:12, SSS_mean, SSS_std, 'LineWidth', 2);

% % BEC SMOS
% load('SSS_SMOS_BEC_Cape_Olyutor.mat')
% psmos_bec = plot(timenum, SSS, '-o');

xticks(1:12)
xlim([0 13])
ylim([32.4 34])
xlabel('Month')
ylabel('psu')
set(gca, 'FontSize', 12)

l = legend([pargo, proms, psmap, psmos], 'ARGO BOA', 'ROMS', 'RSS SMPA v6.0', 'CEC SMOS v10');
l.Location = 'NorthWest';
l.FontSize = 15;

title(['Multi-year mean (', ystr_start, '-', ystr_end, ') area-averaged SSS (', replace(region, '_', ' '), ')'])

print(['cmp_area_avg_SSS_', region, '_climate'], '-dpng')