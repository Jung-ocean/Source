clear; clc; close all

yyyy = 2015; tys = num2str(yyyy);
if yyyy == 9999;
    tys = 'avg';
end

trans = load(['transport_straits_', tys, '.txt'])
%point_name={'Korea', 'Taiwan', 'Tsugaru', 'Soya', 'onshore'};
point_name={'Korea', 'Tsugaru', 'Soya'};

month = 1:12;
len_month = length(month);

% map_J('NWP')
%kn = [1 3 4 2 5];
kn = [1 2 3];

% 
% for n = kn
%     m_plot([kts(4*n - 3), kts(4*n - 1)], [kts(4*n - 2), kts(4*n)], 'linewidth', 2, 'Color', 'Red')
% end

figure; hold on; grid on
for n = kn
    if strcmp(point_name{n}, 'onshore')
        plot(month, -trans(len_month*n-(len_month-1):len_month*n), 'linewidth', 2)
    else
        plot(month, trans(len_month*n-(len_month-1):len_month*n), 'linewidth', 2)
    end
end
xlabel('Month'); ylabel('Transport (Sv)')
xlim([0 13])
ylim([-1.5 4.5])
set(gca, 'FontSize', 15)
h = legend(point_name(kn), 'Location', 'NorthOutside', 'Orientation', 'Horizontal');
h.FontSize = 10;

title(['transport ', tys], 'FontSize', 15)
saveas(gcf, ['transport_straits_', tys,'.png'])

% figure; hold on; grid on
% n = 9;
% plot(1:12, trans(12*n-11:12*n), 'linewidth', 2)
% xlabel('Month'); ylabel('Transport (Sv)')
% xlim([0 13])
% ylim([-20 30])
% title('Luzon', 'FontSize', 15)
% set(gca, 'FontSize', 15)
% saveas(gcf, 'transport_Luzon.png')