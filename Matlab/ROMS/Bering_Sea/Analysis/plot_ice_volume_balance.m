clear; clc; close all

region = 'Koryak_coast_basin';
yyyy_all = 2019:2023;
dt = 60*60*24;
refdate = datenum(1968,5,23);

day_movmean = 7;

ismap = 0;

ylimit = [-10 10];
colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r', '0.0588 1.0000 1.0000'};

figure;
set(gcf, 'Position', [1 1 900 900])
t = tiledlayout(3,1);
nexttile(1); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    dTdt_cumsum = [T_his(1); T_his(1)+cumsum(dt.*dTdt)];

    timenum_his = (t_his/60/60/24 + refdate) - datenum(yyyy-1,1,1);

    p(yi) = plot(timenum_his, movmean(dTdt_cumsum/1e9, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,11:12,1), datenum(1,1:12,1)])
    xlim([datenum(0,11,1) datenum(1,8,1)])
    ylim([0 40])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('km^3')

    set(gca, 'FontSize', 15)

    l = legend(p, '2019', '2020', '2021', '2022', '2023');
    l.Location = 'NorthEast';
    l.FontSize = 15;

    title(['Sea ice volume (', num2str(day_movmean), '-day moving average)'])
end

nexttile(3); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    timenum_avg = (t_avg/60/60/24 + refdate) - datenum(yyyy-1,1,1);

    p(yi) = plot(timenum_avg, movmean(thermo.*dt/1e9, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,11:12,1), datenum(1,1:12,1)])
    xlim([datenum(0,11,1) datenum(1,8,1)])
    ylim(ylimit)
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('km^3/day')

    set(gca, 'FontSize', 15)

    title(['Thermodynamics (', num2str(day_movmean), '-day moving average)'])

    a = thermo.*dt/1e9;
    growth(yi) = sum(a(a>0));
    melt(yi) = sum(a(a<0));
end
plot(0:length(thermo)+1, zeros([1,length(thermo)+2]), '-k')

nexttile(2); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    timenum_avg = (t_avg/60/60/24 + refdate) - datenum(yyyy-1,1,1);

    p(yi) = plot(timenum_avg, movmean(dyn.*dt/1e9, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,11:12,1), datenum(1,1:12,1)])
    xlim([datenum(0,11,1) datenum(1,8,1)])
    ylim(ylimit)
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('km^3/day')

    set(gca, 'FontSize', 15)

    title(['Advection (', num2str(day_movmean), '-day moving average)'])

    b = dyn.*dt/1e9;
    transport(yi) = sum(b);
end
plot(0:length(dyn)+1, zeros([1,length(dyn)+2]), '-k')

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['volume_and_terms_' region], '-dpng')

if ismap == 1
    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Bering', 'mercator', 'l');
    contourm(grd.lat_rho, grd.lon_rho, grd.h, [50 100 200], 'k')
    [c,h] = contourfm(grd.lat_rho, grd.lon_rho, mask_ave, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['area_' region], '-dpng')
end