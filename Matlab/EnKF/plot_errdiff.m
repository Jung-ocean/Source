clear; clc
h = load('rms_1.mat')
d = load('rms_1_daily.mat')
e = load('rms_1_ensmean.mat')

dn = datenum(2016,1,1);

figure; hold on
plot(dn + h.err_diff_sum_all(:,1)/60/60/24, h.err_diff_sum_all(:,2), 'o-', 'LineWidth', 2)
plot(dn + d.err_diff_sum_all(:,1)/60/60/24, d.err_diff_sum_all(:,2), 'o', 'LineWidth', 2)
datetick('x', 'dd')
xlabel('Day'); ylabel('Error Diff (deg C)')
set(gca, 'FontSize', 15)
title('Sum of err diff', 'FontSize', 15)
legend('3-hourly', 'Daily', 'FontSize', 15)
saveas(gcf, 'SumofErrDiff.png')

figure; hold on
plot(dn + h.ada_rms_all(:,1)/60/60/24, h.ada_rms_all(:,2), 'LineWidth', 2)
plot(dn + d.ada_rms_all(:,1)/60/60/24, d.ada_rms_all(:,2), 'LineWidth', 2)
datetick('x', 'dd')
xlabel('Day'); ylabel('RMSE (deg C)')
set(gca, 'FontSize', 15)
title('RMSE', 'FontSize', 15)
legend('3-hourly', 'Daily', 'FontSize', 15, 'Location', 'SouthEast')
saveas(gcf, 'RMSE.png')