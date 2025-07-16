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
mm_all = 8;

is4 = 0;

if length(mm_all) == 1
    title_str = datestr(datenum(0,mm_all,15), 'mmm');
else
    title_str = [datestr(datenum(0,mm_all(1),15), 'mmm'), '-', datestr(datenum(0,mm_all(end),15), 'mmm')];
end

xlimit = [datenum(2015,1,1)-1, datenum(2023,12,31)+1];
names = {'ROMS', 'SMAP', 'SMOS', 'OISSS', 'CMEMS'};
legends = {'ROMS (4 years)', 'SMAP (9 years)', 'SMOS (14 years)'};
colors = {'k', 'r', 'b', 'g', 'm'};
if length(mm_all) == 1
    savename = ['cmp_area_avg_SSSA_', region, '_', num2str(mm_all, '%02i')];
else
    savename = ['cmp_area_avg_SSSA_', region];
end

% filepaths = {
% '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/',    
% '/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/',
% '/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/'
% '/data/jungjih/Observations/Satellite_SSS/OISSS_v2/'
% '/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/'
% };
for fi = 1:5
    filepaths{fi} = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/SSS/', region, '/'];
end

% Figure;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])

for ni = 1:3%length(names)
    name = names{ni};
    filepath = filepaths{ni};
    if length(mm_all) == 1
        filename = ['SSS_', name, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
    else
        filename = ['SSS_', name, '_', region, '.mat'];
    end
    file = [filepath, filename];
    load(file);

    if is4 == 1
        if ni == 2
            timenum = timenum(5:8);
            SSS = SSS(5:8);
        elseif ni == 3
            timenum = timenum(10:13);
            SSS = SSS(10:13);
            savename = [savename, '_4years'];
        end
        xlimit = [datenum(2019,1,1)-1, datenum(2022,12,31)+1];
        legends = {'ROMS (4 years)', 'SMAP (4 years)', 'SMOS (4 years)'};
    else
        if ni == 3
            timenum = timenum(6:end);
            SSS = SSS(6:end);
            legends = {'ROMS (4 years)', 'SMAP (9 years)', 'SMOS (9 years)'};
        end
    end

    if ni == 1
        pmodel_surf = plot(timenum, SSS_surf - mean(SSS_surf), '-o', 'Color', colors{ni}, 'LineWidth', 2);
%         pmodel_bot = plot(timenum, SSS_bot, '--', 'Color', colors{ni}, 'LineWidth', 2);
    else
        p(ni-1) = plot(timenum, SSS - mean(SSS), '-o', 'Color', colors{ni}, 'LineWidth', 2);
    end
end

xlim(xlimit);
ylim([-2.5 2.5])
xticks(datenum(2000:2024,1,1));
datetick('x', 'yyyy', 'keepticks', 'keeplimits');
ylabel('psu')

set(gca, 'FontSize', 15)

l = legend([pmodel_surf, p], legends{1:3});
l.Location = 'SouthWest';
l.FontSize = 15;

title(['SSSA in ', title_str])

if strcmp(region, 'Gulf_of_Anadyr_50m')
    title(['SSSA in ', title_str, ' (> 50 m)'])
elseif strcmp(region, 'Gulf_of_Anadyr_common') & length(mm_all) == 1
    load(['../Gulf_of_Anadyr/SSS_ROMS_Gulf_of_Anadyr_', num2str(mm_all, '%02i'), '.mat']);
    pmodel_surf_entire = plot(timenum, SSS_surf - mean(SSS_surf), '--o', 'Color', 'k', 'LineWidth', 2);

    l = legend([pmodel_surf, pmodel_surf_entire, p], names{1}, 'ROMS (Entire Gulf area)', names{2}, names{3});
    l.Location = 'SouthWest';
    l.FontSize = 15;
end

print(savename, '-dpng')