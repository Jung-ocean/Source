clear; clc; close all

region = 'GOA';
days = 1;
day_movmean = 7;
ylimit = [-0.04 0.04];
FS = 12;

titles = {'(a)', '(b)', '(c)', '(d)'};

yyyy_all = 2019:2022;
colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};

figure;
set(gcf, 'Position', [1 1 900 900])

for yi = 1:length(yyyy_all)

    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/dia/ver_simple/GOA/saltBalance_', region, '_', ystr, '.mat'])

    Sice = Ssurf - Satm;
    % Uflux_river = Uflux_avg - Uflux_open_avg;
    Adv_river = -(Uflux_river.*T_avg)./V_avg;
    Adv_open = dTdt - (Ssurf + Adv_river);

    timenum_his = t_his/60/60/24 + datenum(1968,5,23);
    timenum_avg = t_avg/60/60/24 + datenum(1968,5,23);

    scale = days*24*60*60;
    % Salt balance
%     ptend = plot(timenum_avg, T_his(1)+cumsum(scale.*dTdt), '-k', 'LineWidth', 2);
    subplot('Position', [.1 .82 .8 .15]); hold on; grid on
    psalt(yi) = plot(movmean(T_avg, day_movmean, 'Endpoints', 'fill'), '-', 'Color', colors{yi}, 'LineWidth', 2);
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,1) datenum(0,8,1)])
    ylim([32 34])
    xticklabels('')
    ylabel('psu')
    set(gca, 'FontSize', FS)
    title('(a) Volume-averaged salinity (7-day moving average)')
    box on

    subplot('Position', [.1 .63 .8 .15]); hold on; grid on
    popen = plot(movmean(scale.*Adv_open, day_movmean, 'Endpoints', 'fill'), '-', 'Color', colors{yi}, 'LineWidth', 2);
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,1) datenum(0,8,1)])
    ylim(ylimit)
    xticklabels('')
    ylabel('psu/day')
    set(gca, 'FontSize', FS)
    title('(b) Advection through open boundary (7-day moving average)')
    box on
    plot(0:length(Adv_open)+1, zeros([1,length(Adv_open)+2]), '-k')

    subplot('Position', [.1 .44 .8 .15]); hold on; grid on
    pice = plot(movmean(scale.*Sice, day_movmean, 'Endpoints', 'fill'), '-', 'Color', colors{yi}, 'LineWidth', 2);
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,1) datenum(0,8,1)])
    ylim(ylimit)
    xticklabels('')
    ylabel('psu/day')
    set(gca, 'FontSize', FS)
    title('(c) Ice (7-day moving average)')
    box on
    plot(0:length(Sice)+1, zeros([1,length(Sice)+2]), '-k')

    subplot('Position', [.1 .25 .8 .15]); hold on; grid on
    priver = plot(movmean(scale.*Adv_river, day_movmean, 'Endpoints', 'fill'), '-', 'Color', colors{yi}, 'LineWidth', 2);
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,1) datenum(0,8,1)])
    ylim(ylimit)
    xticklabels('')
    ylabel('psu/day')
    set(gca, 'FontSize', FS)
    title('(d) River (7-day moving average)')
    box on
    plot(0:length(Adv_river)+1, zeros([1,length(Adv_river)+2]), '-k')

    subplot('Position', [.1 .06 .8 .15]); hold on; grid on
    patm = plot(movmean(scale.*Satm, day_movmean, 'Endpoints', 'fill'), '-', 'Color', colors{yi}, 'LineWidth', 2);
    xticks([datenum(0,1:7,1)])
    xlim([datenum(0,1,1) datenum(0,8,1)])
    ylim(ylimit)
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('psu/day')
    set(gca, 'FontSize', FS)
    title('(e) E-P (7-day moving average)')
    box on
    plot(0:length(Satm)+1, zeros([1,length(Satm)+2]), '-k')

%     title([titles{yi}, ' ', ystr]);

%     if yi == 2 | yi == 4
%         yticklabels('')
%         ylabel('')
%     end
end

subplot('Position', [.1 .82 .8 .15]); hold on; grid on
l = legend([psalt], '2019', '2020', '2021', '2022');
l.FontSize = 10;

exportgraphics(gcf,'figure_term_balance_salt_moving.png','Resolution',150)