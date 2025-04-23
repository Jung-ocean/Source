clear; clc; close all

region = 'GOA';
days = 1;
day_movmean = 7;

titles = {'(a)', '(b)', '(c)', '(d)'};

yyyy_all = 2019:2022;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 800])

for yi = 1:length(yyyy_all)

    if yi < 3
        subplot('Position',[.1 + 0.45*(yi-1),.6,.4,.3]); hold on; grid on
    else
        subplot('Position',[.1 + 0.45*(yi-3),.2,.4,.3]); hold on; grid on
    end

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
    ptend = plot(timenum_avg, movmean(scale.*dTdt, day_movmean, 'Endpoints', 'fill'), '-k', 'LineWidth', 2);
    popen = plot(timenum_avg, movmean(scale.*Adv_open, day_movmean, 'Endpoints', 'fill'), '-r', 'LineWidth', 2);
    patm = plot(timenum_avg, movmean(scale.*Satm, day_movmean, 'Endpoints', 'fill'), 'Color', [0.9294 0.6941 0.1255], 'LineWidth', 2);
    priver = plot(timenum_avg, movmean(scale.*Adv_river, day_movmean, 'Endpoints', 'fill'), '-', 'Color', [0.4667 0.6745 0.1882], 'LineWidth', 2);
    pice = plot(timenum_avg, movmean(scale.*Sice, day_movmean, 'Endpoints', 'fill'), '-b', 'LineWidth', 2);

    % presi = plot(timenum_avg, scale.*(dTdt - (Ssurf + Adv_opt)), '--k', 'LineWidth', 1);
    xticks([datenum(yyyy,1:7,1)])
    xlim([datenum(yyyy,1,1) datenum(yyyy,8,1)])
    yticks([-0.04:0.02:0.04])
    ylim([-0.04 0.04])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('psu/day')
    set(gca, 'FontSize', 15)
    
    title([titles{yi}, ' ', ystr]);

    if yi == 2 | yi == 4
        yticklabels('')
        ylabel('')
    end
    box on
end

l = legend([ptend, popen, patm, priver, pice], 'Tendency', 'Transport', 'E-P', 'River', 'Freeze/Melt');
l.Position = [.1 .07 .85 .05]
l.NumColumns = 5;
l.FontSize = 20;
ddd
exportgraphics(gcf,'figure_term_balance_salt.png','Resolution',150)