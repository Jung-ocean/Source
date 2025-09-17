clear; clc; close all

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

gn = grd('NANOOS');

filepath = '/data/jungjih/Observations/Glider/';
files = dir([filepath, '*', ystr, '*']);

figure;
set(gcf, 'Position', [1 200 1300 800]);
t = tiledlayout(2,6);
title(t, {'Glider track', ''}, 'FontSize', 20)

for fi = 1:length(files)
    file = [filepath, files(fi).name];

    data = readtable(file);

    lat = table2array(data(:,8));
    lon = table2array(data(:,9));
    timenum = datenum(table2array(data(:,2)));
    timevec = datevec(timenum);

    for mi = 1:length(mm_all)
        nexttile(mi); hold on;
        if fi == 1
            plot_map('US_west', 'mercator', 'l');
            [cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');
        end

        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');
        mmm = datestr(datenum(yyyy,mm,15), 'mmm');

        tindex = find(timevec(:,2) == mm);
        if isempty(tindex) ~= 1
            plotm(lat(tindex),lon(tindex), '.r');
        end

        title([mmm, ' ', ystr], 'FontSize', 15);

        if mi < 7
            mlabel off
        end
        if mi ~= 1 && mi ~= 7
            plabel off
        end
    end
end

t.Padding = 'compact';
t.TileSpacing = 'compact';

print(['glider_track_' ystr], '-dpng')