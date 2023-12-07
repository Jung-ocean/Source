clear; clc; close all

yyyy = 2001:2013;

xdate = [];
for yi = yyyy
    for mi = 1:12;
        xdate = [xdate; yi mi];
    end
end

trans_korea_all = [];
trans_taiwan_all = [];
trans_tsugaru_all = [];
trans_soya_all = [];
trans_onshore_all = [];

for yi = yyyy
    ty = yi; tys = num2str(ty);

    trans_all = load(['transport_straits_', tys, '.txt']);
    
    trans_korea_all = [trans_korea_all; trans_all(12*1-11:12*1)];
    trans_taiwan_all = [trans_taiwan_all; trans_all(12*3-11:12*3)];
    trans_tsugaru_all = [trans_tsugaru_all; trans_all(12*5-11:12*5)];
    trans_soya_all = [trans_soya_all; trans_all(12*6-11:12*6)];
    trans_onshore_all = [trans_onshore_all; trans_all(12*7-11:12*7)];
end

xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, trans_korea_all, 'LineWidth', 2)
%plot(xdatenum, trans_taiwan_all, 'LineWidth', 2)
plot(xdatenum, trans_tsugaru_all, 'LineWidth', 2, 'color', 'g')
plot(xdatenum, trans_soya_all, 'LineWidth', 2, 'color', 'c')
%plot(xdatenum, -trans_onshore_all, 'LineWidth', 2)
datetick('x', 'yyyy')

ylim([-1 4.5])
xlim([datenum(2000, 12, 31), datenum(2017, 1, 1)])
xlabel('Year', 'fontsize', 25)
ylabel('Transport(sv)', 'fontsize', 25)
set(gca, 'FontSize', 25)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [2001:2016])

h = legend('Korea', 'Tsugaru', 'Soya', 'Location', 'SouthEast');
h.FontSize = 25;
title('Model transport', 'FontSize', 25)