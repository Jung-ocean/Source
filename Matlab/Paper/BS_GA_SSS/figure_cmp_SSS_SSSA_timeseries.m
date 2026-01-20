clear; clc; close all

exp = 'Dsm4';
region = 'Gulf_of_Anadyr_common';
mm_all = 7;

if length(mm_all) == 1
    title_str = datestr(datenum(0,mm_all,15), 'mmm');
else
    title_str = [datestr(datenum(0,mm_all(1),15), 'mmm'), '-', datestr(datenum(0,mm_all(end),15), 'mmm')];
end

names = {'ROMS', 'SMAP', 'SMOS_BEC', 'OISSS', 'CMEMS'};
colors = {'k', 'r', 'b', 'g', 'm'};

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
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'compact';

% SSS
nexttile(1); hold on; grid on
for ni = 1:3%length(names)
    name = names{ni};
    filepath = filepaths{ni};
    if length(mm_all) == 1
        if strcmp(name, 'ROMS')
            filename = ['SSS_', name, '_', exp, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
        else
            filename = ['SSS_', name, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
        end
    else
        filename = ['SSS_', name, '_', region, '.mat'];
    end
    file = [filepath, filename];
    load(file);
    timevec = datevec(timenum);
%     index = find(timevec(:,1) < 2024 & timevec(:,1) > 2014);
    index = find(timevec(:,1) < 2024);
    timenum = timenum(index);
    if strcmp(name, 'ROMS')
        SSS_surf = SSS_surf(index);
    else
        SSS = SSS(index);
        err = err(index);
    end
    if ni == 3
%         timenum = timenum(6:end);
%         SSS = SSS(6:end);
%         err = err(6:end);
        legends = {'ROMS (4 years)', 'SMAP (9 years)', 'SMOS (9 years)'};
    end

    if ni == 1
        pmodel_surf = plot([2019:2022]-2000, SSS_surf, '-o', 'Color', colors{ni}, 'LineWidth', 2);
        %         pmodel_bot = plot(timenum, SSS_bot, '--', 'Color', colors{ni}, 'LineWidth', 2);
    elseif ni == 2
        index = find(timevec(:,1) == 2019);
        SSS(index) = NaN;
        err(index) = NaN;
        p(ni-1) = errorbar([2015:2023]-2000, SSS, err, '-o', 'Color', colors{ni}, 'LineWidth', 2);
    else
        %         p(ni-1) = plot(timenum, SSS, '-o', 'Color', colors{ni}, 'LineWidth', 2);
        p(ni-1) = errorbar([2011:2022]-2000, SSS, err, '-o', 'Color', colors{ni}, 'LineWidth', 2);
    end
end
uistack(p(1), 'bottom')
uistack(p(2), 'bottom')

xlim([2010 2024]-2000);
ylim([28 33])
xticks([2011:2023]-2000);
yticks([25:1:34]);
xlabel('Year')
ylabel('psu')

set(gca, 'FontSize', 15)

title(['(a) Area-averaged SSS in ', title_str])
box on

% Sea ice concentration
load('/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/aice/Gulf_of_Anadyr/Fi_ASI_Gulf_of_Anadyr_06.mat')
timevec = datevec(timenum);
index = find(timevec(:,1) > 2010 & timevec(:,1) < 2024);
aice = Fi(index).*100;
yyyy = timevec(index,1);

color = [0.0745 0.6235 1.0000];

yyaxis right;
set(gca, 'Ycolor', color)
plot(yyyy-2000, aice, '-o', 'LineWidth', 2, 'Color', color);
ylim([0 40])
ylabel('Sea ice concentration in Jun (%)')

l = legend([p, pmodel_surf], 'SMAP', 'SMOS', names{1});
l.Location = 'NorthWest';
l.FontSize = 14;
l.NumColumns = 3;

% SSSA
nexttile(2); hold on; grid on
for ni = 1:3%length(names)
    name = names{ni};
    filepath = filepaths{ni};
    if length(mm_all) == 1
        if strcmp(name, 'ROMS')
            filename = ['SSS_', name, '_', exp, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
        else
            filename = ['SSS_', name, '_', region, '_', num2str(mm_all, '%02i'), '.mat'];
        end
    else
        filename = ['SSS_', name, '_', region, '.mat'];
    end
    file = [filepath, filename];
    load(file);
    timevec = datevec(timenum);
    index = find(timevec(:,1) < 2024 & timevec(:,1) > 2014);
    timenum = timenum(index);
    if strcmp(name, 'ROMS')
        SSS_surf = SSS_surf(index);
    else
        SSS = SSS(index);
        err = err(index);
    end
    if ni == 3
%         timenum = timenum(6:end);
%         SSS = SSS(6:end);
%         err = err(6:end);
    end

    if ni == 1
        pmodel_surf = plot([2019:2022]-2000, SSS_surf - mean(SSS_surf), '-o', 'Color', colors{ni}, 'LineWidth', 2);
    elseif ni == 2
        index = find(timevec(:,1) == 2019);
        SSS(index) = NaN;
        SSSA = SSS - mean(SSS, 'omitnan');
        p(ni-1) = plot([2015:2023]-2000, SSSA, '-o', 'Color', colors{ni}, 'LineWidth', 2);
    else
        p(ni-1) = plot([2015:2022]-2000, SSS - mean(SSS), '-o', 'Color', colors{ni}, 'LineWidth', 2);
    end
end

xlim([2014 2024]-2000);
ylim([-2.5 1])
xticks([2015:2023]-2000);
yticks([-3:1:1.5]);
xlabel('Year')
ylabel('psu')

set(gca, 'FontSize', 15)

% l = legend([p, pmodel_surf], 'SMAP (8-year)', 'SMOS (8-year)', 'ROMS (4-year)');
% l.Location = 'SouthWest';
% l.FontSize = 12;
% l.NumColumns = 3;

title(['(b) Area-averaged SSSA in ', title_str])
box on
fff
exportgraphics(gcf,'figure_cmp_SSS_SSSA_timeseries.tif','Resolution',300)