%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS area averaged SSS to satellite SSS using .mat files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr';

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
    filepaths{fi} = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/SSS/Gulf_of_Anadyr/';
end

% Figure;
figure; hold on; grid on;
set(gcf, 'Position', [1 200 1200 500])
t = tiledlayout(2,1);

nexttile(1); hold on; grid on
% load('/data/jungjih/Observations/Sea_ice/ASI/Fi_ASI_midshelf.mat')
load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/SSS/', region, '/Fi_ASI_', region, '.mat'])
plot(timenum, Fi, 'k', 'LineWidth', 2, 'Color', [0 0.4471 0.7412]);
xlim([datenum(2010,1,1)-1, datenum(2023,12,31)+1]);
ylim([0 1])
xticks(datenum(2000:2024,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits');
ylabel('Sea ice concentration')

title('ASI monthly sea ice concentration')

yyyy_ASI = 2012:2023;
Fi_Apr = Fi(4:12:end);
index = find(Fi_Apr > 0.05);
yyyy_Apr_ice = yyyy_ASI(index);

nexttile(2); hold on; grid on
for ni = 1:3%length(names)
    name = names{ni};
    filepath = filepaths{ni};
    filename = ['SSS_', name, '_', region, '.mat'];
    file = [filepath, filename];
    load(file);

    if ni == 1
        pmodel_surf = plot(timenum, SSS_surf, '-', 'Color', colors{ni}, 'LineWidth', 2);
%         pmodel_bot = plot(timenum, SSS_bot, '--', 'Color', colors{ni}, 'LineWidth', 2);
    else
        p(ni-1) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);
    end
end

xlim([datenum(2010,1,1)-1, datenum(2023,12,31)+1]);
ylim([30.5 34])
xticks(datenum(2000:2024,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits');
ylabel('PSU')

% for yi = 1:length(yyyy_Apr_ice)
%     target_year = yyyy_Apr_ice(yi);
%     x = [datenum(target_year,1,15) datenum(target_year+1,1,15) datenum(target_year+1,1,15) datenum(target_year,1,15)];
%     y = [0 0 100 100];
%     f = fill(x, y, [0 1 1], 'FaceAlpha', 0.3);
%     uistack(f, 'bottom');
% end

l = legend([pmodel_surf, p], names{1:3});
l.Location = 'NorthWest';

title('Monthly SSS')

t.TileSpacing = 'compact';
t.Padding = 'compact';
ff
print(['cmp_area_avg_SSS_', region], '-dpng')