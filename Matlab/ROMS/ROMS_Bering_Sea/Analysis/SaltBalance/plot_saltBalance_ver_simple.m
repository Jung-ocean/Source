clear; clc; close all

yyyy = 2022; ystr = num2str(yyyy);

region = 'GOA';
days = 1;

ismap = 0;

load(['saltBalance_', region, '_', ystr, '.mat'])

Sice = Ssurf - Satm;
% Uflux_river = Uflux_avg - Uflux_open_avg;
Adv_river = -(Uflux_river.*T_avg)./V_avg;
Adv_open = dTdt - (Ssurf + Adv_river);

timenum_his = t_his/60/60/24 + datenum(1968,5,23);
timenum_avg = t_avg/60/60/24 + datenum(1968,5,23);

if ismap == 1
    g = grd('BSf');

    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
    [c,h] = contourfm(grd.lat_rho, grd.lon_rho, mask_ave, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['area_' region], '-dpng')
end

scale = days*24*60*60;
% Salt balance
figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
ptend = plot(timenum_avg, scale.*dTdt, '-k', 'LineWidth', 2);
priver = plot(timenum_avg, scale.*Adv_river, '-b', 'LineWidth', 2);
pice = plot(timenum_avg, scale.*Sice, '-', 'Color', [0.0588 1.0000 1.0000], 'LineWidth', 2);
popen = plot(timenum_avg, scale.*Adv_open, '-r', 'LineWidth', 2);
patm = plot(timenum_avg, scale.*Satm, 'Color', [0.7176 0.2745 1.0000], 'LineWidth', 2);
% presi = plot(timenum_avg, scale.*(dTdt - (Ssurf + Adv_opt)), '--k', 'LineWidth', 1);
xticks([datenum(yyyy,1:12,1)])
xlim([datenum(yyyy,5,1) datenum(yyyy,8,1)])
ylim([-0.04 0.04])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylabel('psu/day')
set(gca, 'FontSize', 15)
% l = legend([ptend, priver, pice, popen, patm, presi], 'Tend', 'Adv (river)', 'Ice', 'Adv (open)', 'E-P', 'residual');
l = legend([ptend, priver, pice, popen, patm], 'Tend', 'Adv (river)', 'Ice', 'Adv (open, est.)', 'E-P');
l.FontSize = 20;
l.Location = 'SouthOutside';
l.NumColumns = 4;
print(['saltBalance_' region, '_', ystr], '-dpng')

% if strcmp(region, 'GOA')
%     % Ice and river
%     figure; hold on; grid on
%     set(gcf, 'Position', [1 200 800 500])
%     plot(timenum_avg, aice_avg, '-k', 'LineWidth', 2);
%     ylim([0 1])
%     xticks([datenum(2021,1:12,1)])
%     xlim([datenum(2021,5,1) datenum(2021,7,1)])
%     datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
%     ylabel('Sea ice concentration')
%     yyaxis right
%     ax = gca;
%     set(ax, 'YColor', 'b')
%     load ../discharge_Anadyr_2021.mat
%     plot(datenum(2021,1,1):datenum(2021,12,31), dis_total, '-b', 'LineWidth', 2);
%     ylabel('river discharge (m^3/s)')
%     set(gca, 'FontSize', 15)
%     print(['Ice_and_river_' region], '-dpng')
% end