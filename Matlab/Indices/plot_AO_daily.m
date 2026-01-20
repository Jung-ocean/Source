clear; clc

yyyy_all = 2019:2022;
mm_start = 3;
dd_start = 1;
mm_end = 6;
dd_end = 30;

timenum_plot = [datenum(1,mm_start,dd_start):datenum(1,mm_end,dd_end)]';
xlimit = [timenum_plot(1)-1 timenum_plot(end)+1];
colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};
FS = 12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);

    timenum_tmp = datenum(yyyy,mm_start,dd_start):datenum(yyyy,mm_end,dd_end);
    vari_tmp = load_AO_daily(timenum_tmp);

    p(yi) = plot(timenum_plot, vari_tmp, 'LineWidth', 2, 'Color', colors{yi});
end

plot(timenum_plot, 0.*timenum_plot, '-k')
xlim([xlimit])
ylim([-6 6])
xticks(datenum(1,1:12,1));
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
xlabel('Date')
set(gca,'FontSize', FS)

l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'SouthEast';
l.NumColumns = 4;
l.FontSize = 15;

title('Arctic Oscillation (AO)', 'FontSize', 15)

print('AO_daily', '-dpng')