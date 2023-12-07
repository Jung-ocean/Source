y = 1:365;
rmin = 6e-4;
rmax = 3e-3;
tm = 195;
tef = 90;

rdrg2 = rmax-(rmax-rmin)*exp(-((y-tm)/tef).^2)

figure; hold on; grid on
plot(y, rdrg2, 'LineWidth', 2)
xlabel('Day')
ylabel('Bottom drag coefficient')
set(gca, 'FontSize', 15)

saveas(gcf, 'rdrg2_timevarying.png')