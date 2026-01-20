%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged SSS to satellite SSS using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr_common';
mm_all = 7:7;
mstr = num2str(mm_all, '%02i');

if length(mm_all) == 1
    title_str = datestr(datenum(0,mm_all,15), 'mmm');
else
    title_str = [datestr(datenum(0,mm_all(1),15), 'mmm'), '-', datestr(datenum(0,mm_all(end),15), 'mmm')];
end

isSMOS_BEC = 1;

names = {'SMAP', 'SMOS', 'SMOS_BEC', 'ROMS'};
colors = {'r', 'b', '[0.4667 0.6745 0.1882]', 'k'};

ylimit = [25 34];

for fi = 1:length(names)
    filepaths{fi} = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/'];
end

% Figure;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])

% SMAP
ni = 1;
filename = ['SSS_', names{ni}, '_', region, '_', mstr, '.mat'];
load([filepaths{ni}, filename]);
SSS(5) = NaN;
p(ni) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);

% SMOS
ni = 2;
filename = ['SSS_', names{ni}, '_', region, '_', mstr, '.mat'];
load([filepaths{ni}, filename]);
p(ni) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);

% load('SSS_SMOS_v10_Gulf_of_Anadyr_common_07');
% plot(timenum, SSS, '*', 'Color', colors{ni}, 'LineWidth', 2, 'MarkerSize', 10);

% SMOS BEC
ni = 3;
filename = ['SSS_', names{ni}, '_', region, '_', mstr, '.mat'];
load([filepaths{ni}, filename]);
p(ni) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);

title(['Area-averaged SSS in ', title_str])

% ROMS
ni = 4;
filename = ['SSS_', names{ni}, '_', exp, '_', region, '_', mstr, '.mat'];
load([filepaths{ni}, filename]);
p(ni) = plot(timenum, SSS_surf, '-o', 'Color', colors{ni}, 'LineWidth', 2);

xlim([datenum(2010,1,1)-1, datenum(2025,12,31)+1]);
ylim(ylimit)
xticks(datenum(2000:2025,mm_all,15));
datetick('x', 'yy', 'keepticks', 'keeplimits');
xtickangle(0);
xlabel('Year')
ylabel('psu')
set(gca, 'FontSize', 15)

load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr/SSS_ROMS_Gulf_of_Anadyr_', mstr, '.mat']);
plot(timenum, SSS_surf, '--o', 'Color', colors{ni}, 'LineWidth', 2);

if strcmp(region, 'Gulf_of_Anadyr_50m')
    title(['Area-averaged SSS in ', title_str, ' (> 50 m)'])
elseif strcmp(region, 'Gulf_of_Anadyr_common') & length(mm_all) == 1
    if isSMOS_BEC == 1
        l = legend(p, 'SMAP', 'SMOS CEC', 'SMOS BEC', 'ROMS (dashed = entire gulf)');
        l.Location = 'SouthWest';
        l.FontSize = 15;
    else
        delete(p(3));
        l = legend(p([1 2 4]), 'SMAP', 'SMOS', 'ROMS (dashed = entire gulf)');
        l.Location = 'SouthWest';
        l.FontSize = 15;
    end
end

% if mm_all == 8
%     load('/data/jungjih/Observations/Nomura_etal_2021/data_Nomura_etal_2021.mat')
%     N2021 = plot(datenum(2018,8,15), SSS_mean, '*', 'Color', [0.4667 0.6745 0.1882], 'LineWidth', 3, 'MarkerSize', 15);
%
%     l = legend([pmodel_surf, pmodel_surf_entire, p, N2021], names{1}, 'ROMS (Entire Gulf area)', names{2}, names{3}, 'Nomura et al. (2021)');
%     l.Location = 'SouthWest';
%     l.FontSize = 15;
% end

if length(mm_all) == 1
    if isSMOS_BEC == 1
        print(['cmp_area_avg_SSS_', region, '_', num2str(mm_all, '%02i'), '_w_SMOS_BEC'], '-dpng')
    else
        print(['cmp_area_avg_SSS_', region, '_', num2str(mm_all, '%02i')], '-dpng')
    end
else
    print(['cmp_area_avg_SSS_', region], '-dpng')
end