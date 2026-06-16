clear; clc

ncpus = [20 40 80 160];
times = [2703.855 1775.603 1020.408 761.255];

ntimes = 7200;
dt = 60;
ndays = ntimes*dt/60/60/24;
minutes_per_day = times./60/ndays;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot(ncpus, minutes_per_day, '-ko', 'LineWidth', 2, 'MarkerSize', 10);
xlim([20 160]);
xticks(ncpus)
yticks([0:10])
ylim([0 10]);
xlabel('ncpus');
ylabel('Average minutes per day')

set(gca, 'FontSize', 15)

title(['5-day simulations (dt = ', num2str(dt), ' s)'])

print('speed_by_core', '-dpng')