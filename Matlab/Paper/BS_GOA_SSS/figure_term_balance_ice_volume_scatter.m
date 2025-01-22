clear; clc; close all

region = 'GOA';
yyyy_all = 2019:2022;
mm_all = 1:7;
dt = 60*60*24;
refdate = datenum(1968,5,23);

day_start = 1;
day_end = 91;

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ice_volume/ice_volume_Balance_', region, '_', ystr, '.mat']);
    
    dTdt_cumsum = [cumsum(dt.*dTdt)];
    thermo_cumsum = [cumsum(dt.*thermo)];
    dyn_cumsum = [cumsum(dt.*dyn)];

    delta_ice(yi) = T_his(day_end) - T_his(day_start);
    thermo_cumsum_target(yi) = thermo_cumsum(day_end - 1);
    dyn_cumsum_target(yi) = dyn_cumsum(day_end - 1);

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

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 800])

for yi = 1:length(yyyy_all)
    p(yi) = plot(thermo_cumsum_target(yi), delta_ice(yi), 'o', 'MarkerSize', 12, 'MarkerFaceColor', colors{yi}, 'MarkerEdgeColor', 'none');
end
plot([0 1e7], [0 1e7], '-k')
axis equal
xlim([0 5e6])
ylim([0 5e6])
xticks([0:1e6:5e6])
yticks([0:1e6:5e6])
xlabel('cumsum of thermodynamics from Jan 1 to Mar 31 (m^3)')
ylabel('Difference in ice volume between Apr 1 and  Jan 1 (m^3)')
set(gca, 'FontSize', 12)

l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'NorthWest';
l.FontSize = 20;
dfdfdf
exportgraphics(gcf,'figure_term_balance_ice_volume_scatter.png','Resolution',150)