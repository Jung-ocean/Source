%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged SSS to satellite SSS using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr';
mm_all = 7;
region_ice = 'Gulf_of_Anadyr';
mm_ice = 6;

if length(mm_all) == 1
    title_str = datestr(datenum(0,mm_all,15), 'mmm');
else
    title_str = [datestr(datenum(0,mm_all(1),15), 'mmm'), '-', datestr(datenum(0,mm_all(end),15), 'mmm')];
end
title_ice_str = datestr(datenum(0,mm_ice,15), 'mmm');

names = {'ROMS', 'SMAP', 'SMOS', 'OISSS', 'CMEMS'};
colors = {'k', 'r', 'b', 'g', 'm'};

% filepaths = {
% '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/',    
% '/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/',
% '/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/'
% '/data/jungjih/Observations/Satellite_SSS/OISSS_v2/'
% '/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/'
% };
for fi = 1:5
    filepaths{fi} = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/SSS/', region, '/'];
end

% Figure;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 500])
t = tiledlayout(2,1);

nexttile(1); hold on; grid on
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/SSS/', region, '/Fi_ASI_', region_ice, '_', num2str(mm_ice, '%02i'), '.mat'])

plot(timenum, Fi, '-o', 'LineWidth', 2, 'Color', [0 0.4471 0.7412]);
xlim([datenum(2010,1,1)-1, datenum(2023,12,31)+1]);
ylim([0 0.2])
xticks(datenum(2000:2024,1,1));
datetick('x', 'yyyy', 'keepticks', 'keeplimits');
ylabel('Sea ice concentration')

title(['ASI monthly sea ice concentration in ', title_ice_str])

% yyyy_ASI = 2012:2023;
% Fi_Apr = Fi(4:12:end);
% index = find(Fi_Apr > 0.05);
% yyyy_Apr_ice = yyyy_ASI(index);

nexttile(2); hold on; grid on
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

    if ni == 1
        pmodel_surf = plot(timenum, SSS_surf, '-o', 'Color', colors{ni}, 'LineWidth', 2);
%         pmodel_bot = plot(timenum, SSS_bot, '--', 'Color', colors{ni}, 'LineWidth', 2);
    else
        p(ni-1) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);
    end
end

xlim([datenum(2010,1,1)-1, datenum(2023,12,31)+1]);
ylim([27.5 32.5])
xticks(datenum(2000:2024,1,1));
datetick('x', 'yyyy', 'keepticks', 'keeplimits');
ylabel('psu')

% for yi = 1:length(yyyy_Apr_ice)
%     target_year = yyyy_Apr_ice(yi);
%     x = [datenum(target_year,1,15) datenum(target_year+1,1,15) datenum(target_year+1,1,15) datenum(target_year,1,15)];
%     y = [0 0 100 100];
%     f = fill(x, y, [0 1 1], 'FaceAlpha', 0.3);
%     uistack(f, 'bottom');
% end

l = legend([pmodel_surf, p], names{1:3});
l.Location = 'SouthWest';
l.FontSize = 15;

title(['Monthly SSS in ', title_str])

t.TileSpacing = 'compact';
t.Padding = 'compact';

if length(mm_all) == 1
    print(['cmp_area_avg_SSS_', region, '_', num2str(mm_all, '%02i')], '-dpng')
else
    print(['cmp_area_avg_SSS_', region], '-dpng')
end