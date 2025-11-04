clear; clc

yyyy_all = 2019:2022;
mm_all = 1:7;

colors = {'0.9294 0.6941 0.1255', '0.4667 0.6745 0.1882', 'b', 'r'};
FS = 12;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);

    vari_tmp = load_PDO(yyyy, mm_all);

    p(yi) = plot(mm_all, vari_tmp, '-o', 'LineWidth', 2, 'Color', colors{yi});
end
plot([mm_all(1)-1:mm_all(end)+1], 0.*[mm_all(1)-1:mm_all(end)+1], '-k')
xlim([mm_all(1)-.5 mm_all(end)+.5])
ylim([-4 4])
xticks(mm_all);
xlabel('Month')
set(gca,'FontSize', FS)

l = legend(p, '2019', '2020', '2021', '2022');
l.Location = 'NorthWest';
l.NumColumns = 4;
l.FontSize = 15;

title('Pacific Decadal Oscillation (PDO)', 'FontSize', 15)

print('PDO', '-dpng')