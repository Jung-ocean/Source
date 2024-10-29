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

    rmse(yi) = sqrt(mean( (dTdt-(thermo+dyn)).^2 ));

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


figure;
set(gcf, 'Position', [1 1 900 900])
t = tiledlayout(3,1);
nexttile(1); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['ice_volume_Balance_', region, '_', ystr, '.mat']);
    dTdt_cumsum = [T_his(1); T_his(1)+cumsum(dt.*dTdt)];

    p(yi) = plot(dTdt_cumsum, 'LineWidth', 2);
    xticks([datenum(0,1:8,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([0 5e6])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3')

    set(gca, 'FontSize', 15)

    l = legend(p, '2019', '2020', '2021', '2022');
    l.Location = 'NorthEast';
    l.FontSize = 15;

    title('Sea ice volume')
end

nexttile(2); hold on; grid on
b = bar([1 2], [thermo_monthly(:,5)'; thermo_monthly(:,6)']);
for yi = 1:length(yyyy_all)
    b(yi).FaceColor = p(yi).Color;
end
ylim([-0.7 0.2])
xticks([1 2])
xticklabels({'May', 'Jun'})
ylabel('m^3/s')
set(gca, 'FontSize', 15)
title('Thermodynamics (monthly)')

nexttile(3); hold on; grid on
b = bar([1 2], [dyn_monthly(:,5)'; dyn_monthly(:,6)']);
for yi = 1:length(yyyy_all)
    b(yi).FaceColor = p(yi).Color;
end
ylim([-0.7 0.2])
xticks([1 2])
xticklabels({'May', 'Jun'})
ylabel('m^3/s')
set(gca, 'FontSize', 15)
title('Advection (monthly)')

print('volume_and_terms', '-dpng')

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

print('ice_volume_Balance_GOA', '-dpng')
