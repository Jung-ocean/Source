clear; clc; close all

region = 'GOA';
yyyy_all = 2019:2022;
mm_all = 1:7;
dt = 60*60*24;
refdate = datenum(1968,5,23);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    
    dTdt_cumsum = [T_his(1); T_his(1)+cumsum(dt.*dTdt)];
    thermo_cumsum = [cumsum(dt.*thermo)];
    dyn_cumsum = [cumsum(dt.*dyn)];

    timenum = refdate + t_avg/60/60/24;
    timevec = datevec(timenum);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        index = find(timevec(:,1) == yyyy & timevec(:,2) == mm);
        
        dTdt_monthly(yi,mi) = mean(dTdt(index));
        thermo_monthly(yi,mi) = mean(thermo(index));
        dyn_monthly(yi,mi) = mean(dyn(index));
        
        dTdt_cumsum_monthly(yi,mi) = mean(dTdt_cumsum(index));
        thermo_cumsum_monthly(yi,mi) = mean(thermo_cumsum(index));
        dyn_cumsum_monthly(yi,mi) = mean(dyn_cumsum(index));
    end
end

day_movmean = 7;

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'}

figure;
set(gcf, 'Position', [1 1 900 900])
t = tiledlayout(3,1);
nexttile(1); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    dTdt_cumsum = [T_his(1); T_his(1)+cumsum(dt.*dTdt)];

    p(yi) = plot(movmean(dTdt_cumsum, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:8,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([0 5e6])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3')

    set(gca, 'FontSize', 15)

    l = legend(p, '2019', '2020', '2021', '2022');
    l.Location = 'NorthEast';
    l.FontSize = 15;

    title(['Sea ice volume (', num2str(day_movmean), '-day moving average)'])
end

nexttile(3); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    p(yi) = plot(movmean(thermo, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:8,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([-3.5 3.5])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3/s')

    set(gca, 'FontSize', 15)

    title(['Thermodynamics (', num2str(day_movmean), '-day moving average)'])
end
plot(0:length(thermo)+1, zeros([1,length(thermo)+2]), '-k')

nexttile(2); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    p(yi) = plot(movmean(dyn, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:8,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([-3.5 3.5])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3/s')

    set(gca, 'FontSize', 15)

    title(['Advection (', num2str(day_movmean), '-day moving average)'])
end
plot(0:length(dyn)+1, zeros([1,length(dyn)+2]), '-k')

t.TileSpacing = 'compact';
t.Padding = 'compact';
vgfg
print('volume_and_terms', '-dpng')

% Daily
figure;
set(gcf, 'Position', [1 200 1900 450])
t = tiledlayout(1,4);
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    rmse = sqrt(mean( (dTdt-(thermo+dyn)).^2 ));
    len_data = length(dTdt);

    nexttile(yi); hold on; grid on;
    prate = plot(1:len_data, dTdt, '-k', 'LineWidth', 2);
%     pthermo = plot(len_data, thermo_monthly(yi,:), '-or', 'LineWidth', 2);
%     pdyn = plot(len_data, dyn_monthly(yi,:), '-ob', 'LineWidth', 2);
    psum = plot(1:len_data, (thermo+dyn), '-m');
%     xticks(mm_all)
%     xlim([0 8])
    ylim([-10 10])
    xlabel('YTD')
    set(gca, 'FontSize', 12)

    text(130, 8, ['RMSE = ', num2str(rmse, '%.2f'), ' m^3/s'], 'FontSize', 15)

    if yi == 1
        ylabel('Tendency (m^3/s)')
        l = legend([prate, psum], 'dVice/dt', 'Thermodynamics+Advection');
        l.Location = 'SouthOutside';
        l.Layout.Tile = 'South';
        l.FontSize = 20;
        l.NumColumns = 4;
    end
    title(ystr, 'FontSize', 15)
end
t.TileSpacing = 'compact';
t.Padding = 'compact';

print('ice_volume_Balance_GOA_daily', '-dpng')

% Monthly
figure;
set(gcf, 'Position', [1 200 1900 450])
t = tiledlayout(1,4);
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    nexttile(yi); hold on; grid on;
    prate = plot(mm_all, dTdt_monthly(yi,:), '-ok', 'LineWidth', 2);
    pthermo = plot(mm_all, thermo_monthly(yi,:), '-or', 'LineWidth', 2);
    pdyn = plot(mm_all, dyn_monthly(yi,:), '-ob', 'LineWidth', 2);
    psum = plot(mm_all, (thermo_monthly(yi,:)+dyn_monthly(yi,:)), '--m');
    xticks(mm_all)
    xlim([0 8])
    ylim([-1.5 1.5])
    xlabel('Month')
    set(gca, 'FontSize', 12)

    if yi == 1
        ylabel('Tendency (m^3/s)')
        l = legend([prate, pthermo, pdyn, psum], 'dVice/dt', 'Thermo', 'Dyn', 'Thermo+Dyn');
        l.Location = 'SouthOutside';
        l.Layout.Tile = 'South';
        l.FontSize = 20;
        l.NumColumns = 4;
    end
    title(ystr, 'FontSize', 15)
end
t.TileSpacing = 'compact';
t.Padding = 'compact';

print('ice_volume_Balance_GOA_monthly', '-dpng')
