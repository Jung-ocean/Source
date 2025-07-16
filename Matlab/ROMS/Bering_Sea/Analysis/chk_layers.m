clear; clc; close all

g = grd('BSf');

theta_s = 7;
theta_b = 3;
hc = 100;
N = g.N;

depths = [10, 50, 100, 500, 1000, 2000, 3000, 4000];
ylimit = [-150 0];

figure; 
set(gcf, 'Position', [1 200 1300 800])
plot_map('Bering', 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [depths], '-k');
cl = clabelm(cs, h);
set(cl, 'BackgroundColor', 'none');

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 800])

for di = 1:length(depths)
    depth = depths(di);
    z_w(:,di) = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'w',2));
    z_r(:,di) = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'r',2));
end

plot(1:length(depths), z_w, '-k');
xlim([1-.1 length(depths)+.1])
ylim(ylimit)

for zi = 1:length(depths)
    z_tmp = z_r(:,zi);
    index = find(z_tmp > ylimit(1));
    text(zi+0.*z_tmp(index)-.05, z_tmp(index), num2cell(index), 'Color', 'r')
end

xlabel('Total depth (m)')
ylabel('Depth (m)')
xticklabels(num2cell(depths))

set(gca, 'FontSize', 15)

title(['\theta_s = ', num2str(theta_s), '    \theta_b = ', num2str(theta_b), '    hc = ', num2str(hc), ' m'], 'FontSize', 20)

print(['layer_theta_s_', num2str(theta_s), '_theta_b_', num2str(theta_b), '_hc_', num2str(hc), 'm'], '-dpng')