clear; clc; close all

region = 'GOA';
days = 1;

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
    ptend = plot(timenum_avg, T_his(1)+cumsum(scale.*dTdt), '-k', 'LineWidth', 2);
    popen = plot(timenum_avg, T_his(1)+cumsum(scale.*Adv_open), '-r', 'LineWidth', 2);
    patm = plot(timenum_avg, T_his(1)+cumsum(scale.*Satm), 'Color', [0.9294 0.6941 0.1255], 'LineWidth', 2);
    priver = plot(timenum_avg, T_his(1)+cumsum(scale.*Adv_river), '-', 'Color', [0.4667 0.6745 0.1882], 'LineWidth', 2);
    pice = plot(timenum_avg, T_his(1)+cumsum(scale.*Sice), '-b', 'LineWidth', 2);

    ice = T_his(1)+cumsum(scale.*Sice);
    index = find(ice == max(ice));
    plot([timenum_avg(index) timenum_avg(end)], [max(ice) max(ice)], '--b');
    salt_decrease = max(ice) - ice(end);
    if yi == 1
        annotation('textbox',...
            [0.501 0.785 0.04 0.03],...
            'String',num2str(salt_decrease, '%.2f'), ...
            'FontSize', 12, 'Color', 'b', 'EdgeColor','none');
    elseif yi == 2
        annotation('textbox',...
            [0.951 0.807 0.04 0.03],...
            'String',num2str(salt_decrease, '%.2f'), ...
            'FontSize', 12, 'Color', 'b', 'EdgeColor','none');
    elseif yi == 3
        annotation('textbox',...
            [0.501 0.427 0.04 0.03],...
            'String',num2str(salt_decrease, '%.2f'), ...
            'FontSize', 12, 'Color', 'b', 'EdgeColor','none');
    else
        annotation('textbox',...
            [0.951 0.430 0.04 0.03],...
            'String',num2str(salt_decrease, '%.2f'), ...
            'FontSize', 12, 'Color', 'b', 'EdgeColor','none');
    end
        
    if yyyy == 2021
        a = annotation('doublearrow',[0.49 0.49], [0.475 0.405], 'LineWidth', 1, 'Color', 'b');
        text('String',{'Salinity decrease','due to sea ice'},...
            'Position',[738313.846153846 33.6833333333333 1.4210854715202e-14], 'Color', 'b');
    end

    % presi = plot(timenum_avg, scale.*(dTdt - (Ssurf + Adv_opt)), '--k', 'LineWidth', 1);
    xticks([datenum(yyyy,1:7,1)])
    xlim([datenum(yyyy,1,1) datenum(yyyy,8,1)])
    
%     yticks([-0.04:0.01:0.05])
    ylim([32 34])
    datetick('x', 'mmm', 'keepticks', 'keeplimits')
    ylabel('psu')
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
dd
exportgraphics(gcf,'figure_term_balance_salt_cumsum.png','Resolution',150)