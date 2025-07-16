clear; clc; close all

region = 'GOA';
yyyy_all = 2019:2022;
mm_all = 1:7;
dt = 60*60*24;
refdate = datenum(1968,5,23);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    
    dTdt_cumsum = [cumsum(dt.*dTdt)];
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

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};

figure;
set(gcf, 'Position', [1 1 900 900])
subplot('Position', [.1 .7 .8 .25]); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    dTdt_cumsum = [T_his(1); T_his(1)+cumsum(dt.*dTdt)];

    p(yi) = plot(movmean(dTdt_cumsum, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([0 5e6])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3')

    set(gca, 'FontSize', 15)

%     title(['(a) Sea ice volume (', num2str(day_movmean), '-day moving average)'])
    title(['(a) Sea ice volume'])
end
plot([datenum(0,4,2) datenum(0,4,2)], [0 1e7], '-k')
plot([datenum(0,4,10) datenum(0,4,10)], [0 1e7], '-k')
plot([datenum(0,4,30) datenum(0,4,30)], [0 1e7], '-k')
xticklabels('')
box on

l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'NorthEast';
l.FontSize = 18;

subplot('Position', [.1 .4 .8 .25]); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    p(yi) = plot(movmean(dyn, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([-3.5 3.5])
    yticks(-3:1:3)
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3/s')

    set(gca, 'FontSize', 15)

%     title(['(b) Advection (', num2str(day_movmean), '-day moving average)'])
    title(['(b) Advection'])
end
plot(0:length(dyn)+1, zeros([1,length(dyn)+2]), '-k')
plot([datenum(0,4,2) datenum(0,4,2)], [-4 4], '-k')
plot([datenum(0,4,10) datenum(0,4,10)], [-4 4], '-k')
plot([datenum(0,4,30) datenum(0,4,30)], [-4 4], '-k')
xticklabels('')
box on

subplot('Position', [.1 .1 .8 .25]); hold on; grid on
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/ice_volume_Balance_', region, '_', ystr, '_new.mat']);
    p(yi) = plot(movmean(thermo, day_movmean, 'Endpoints', 'fill'), 'LineWidth', 2, 'Color', colors{yi});
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,0) datenum(0,8,1)])
    ylim([-3.5 3.5])
    yticks(-3:1:3)
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('m^3/s')

    set(gca, 'FontSize', 15)

%     title(['(c) Thermodynamics (', num2str(day_movmean), '-day moving average)'])
    title(['(c) Thermodynamics'])

end
plot(0:length(thermo)+1, zeros([1,length(thermo)+2]), '-k')
box on
asdf
exportgraphics(gcf,'figure_term_balance_ice_volume.png','Resolution',150)