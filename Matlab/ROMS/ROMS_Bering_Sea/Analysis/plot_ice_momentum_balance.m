clear; clc; close all

yyyy = 2021;
ystr = num2str(yyyy);

if yyyy == 2022
    ylimit = [-.8e-4 .8e-4];
else
    ylimit = [-3e-4 3e-4];
end

ismap = 1;
cutoff_hice = 0.1;
day_movmean = 1;

load(['ice_momentum_balance_', ystr, '.mat'])

if ismap == 1
    g = grd('BSf');

    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Gulf_of_Anadyr', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
    plotm(lat, lon, 'xk', 'MarkerSize', 30, 'LineWidth', 8)
    print(['point_momentum_balance_', ystr], '-dpng')
end

% Plot
figure; hold on; grid on;
set(gcf, 'Position', [1 1 900 700])
t = tiledlayout(2,1);

nexttile(1); hold on; grid on
direction = 'u';
varis = {'accel', 'adv', 'cor', 'grd', 'ostr', 'astr', 'istr'};
legends = {'Acceleration', 'Advection', 'Coriolis', 'Sea level gradient', 'Ocean-ice stress', 'Wind-ice stress', 'Internal stress'};
sum = zeros;
for vi = 1:length(varis)
    vari = movmean(eval([direction, '_', varis{vi}]),day_movmean);
    vari(hi_u < cutoff_hice) = NaN;
    if vi == 1
    p(vi) = plot(timenum, vari, '-k', 'LineWidth', 2);
    else
    p(vi) = plot(timenum, vari, 'LineWidth', 2);
    sum = sum+vari;
    end
end
psum = plot(timenum, sum, '--m');
uistack(p(3), 'top')
xticks(timenum(1:5:end))
xlim([timenum(1) timenum(end)]);
ylim([-3e-4 3e-4])
datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
ylabel('m^2/s^2')
set(gca, 'FontSize', 15)

title(['Zonal balance (', num2str(day_movmean), '-day moving average)'])

nexttile(2); hold on; grid on
direction = 'v';
sum = zeros;
for vi = 1:length(varis)
    vari = movmean(eval([direction, '_', varis{vi}]),day_movmean);
    vari(hi_v < cutoff_hice) = NaN;
    if vi == 1
    p(vi) = plot(timenum, vari, '-k', 'LineWidth', 2);
    else
    p(vi) = plot(timenum, vari, 'LineWidth', 2);
    sum = sum+vari;
    end
end
psum = plot(timenum, sum, '--m');
uistack(p(3), 'top')
xticks(timenum(1:5:end))
xlim([timenum(1) timenum(end)]);
ylim(ylimit)
datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
ylabel('m^2/s^2')
set(gca, 'FontSize', 15)

title(['Meridional balance (', num2str(day_movmean), '-day moving average)'])

l = legend([p psum], [legends, 'sum']);
l.Location = 'Southoutside';
l.NumColumns = 4;

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['momentum_balance_', ystr], '-dpng')

% Estimated uice
direction = 'v';
% ui_dia = (v_grd + v_ostr + v_astr + v_istr)./(hif_v);
% vi_dia = (u_grd + u_ostr + u_astr + u_istr)./(-hif_u);
ui_v = movmean(ui_v, day_movmean);
ui_v(hi_v < cutoff_hice) = NaN;

sum = zeros;
for vi = [4 5 6 7]
        vari = movmean(eval([direction, '_', varis{vi}]), day_movmean);
%     vari = eval([direction, '_', varis{vi}]);
    vari(hi_v < cutoff_hice) = NaN;
    sum = sum+vari;
end
ui_dia = sum./hif_v;

figure; hold on; grid on;
set(gcf, 'Position', [1 1 900 300])
p1 = plot(timenum, ui_v, 'k', 'LineWidth', 2);
p2 = plot(timenum, ui_dia, '--r', 'LineWidth', 2);
plot(timenum, timenum.*0, '-k')
xticks(timenum(1:5:end))
xlim([timenum(1) timenum(end)]);
ylim([-1 1])
datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
ylabel('m/s')
set(gca, 'FontSize', 15)

l = legend([p1, p2], {'uice', 'uice from momentum balance'});
l.Location = 'SouthEast';

title(['Zonal ice velocity'])

print(['cmp_uice_', ystr], '-dpng')

% Estimated vice
direction = 'u';
% ui_dia = (v_grd + v_ostr + v_astr + v_istr)./(hif_v);
% vi_dia = (u_grd + u_ostr + u_astr + u_istr)./(-hif_u);
vi_u = movmean(vi_u, day_movmean);
vi_u(hi_u < cutoff_hice) = NaN;

sum = zeros;
for vi = [4 5 6 7]
        vari = movmean(eval([direction, '_', varis{vi}]), day_movmean);
%     vari = eval([direction, '_', varis{vi}]);
    vari(hi_u < cutoff_hice) = NaN;
    sum = sum+vari;
end
vi_dia = sum./(-hif_u);

figure; hold on; grid on;
set(gcf, 'Position', [1 1 900 300])
p1 = plot(timenum, vi_u, 'k', 'LineWidth', 2);
p2 = plot(timenum, vi_dia, '--r', 'LineWidth', 2);
plot(timenum, timenum.*0, '-k')
xticks(timenum(1:5:end))
xlim([timenum(1) timenum(end)]);
ylim([-1 1])
datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
ylabel('m/s')
set(gca, 'FontSize', 15)

l = legend([p1, p2], {'vice', 'vice from momentum balance'});
l.Location = 'SouthEast';

title(['Meridional ice velocity'])

print(['cmp_vice_', ystr], '-dpng')