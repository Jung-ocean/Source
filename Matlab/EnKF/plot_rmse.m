clear; clc; close all
load rms_1_daily.mat
plot(bda_rms_all(:,2), 'LineWidth', 2)
hold on
plot(ada_rms_all(:,2), 'LineWidth', 2)
legend('Before', 'After', 'Location', 'SouthWest')
xlabel('Day'); ylabel('RMSE (degC)')
set(gca, 'FontSize', 15)
title('1 degree from DA spot', 'FontSize', 15)
%ylim([0 3])
saveas(gcf, 'rmse_diff_1deg.png')