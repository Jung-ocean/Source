clear; clc; close all

g = grd('BSf');

theta_s = 2;
theta_b = 0;
hc = 50;

depth = 3800;
dstr = num2str(depth);
Ns = [g.N 100 200];
ylimit = [-500 0];

figure; 
set(gcf, 'Position', [1 200 1300 800])
plot_map('Bering', 'mercator', 'l');
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [depth depth], '-k');
cl = clabelm(cs, h);
set(cl, 'BackgroundColor', 'none');

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 800])

for ni = 1:length(Ns)
    N = Ns(ni);
    z_w = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'w',2));
    z_r = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N,'r',2));

    plot(ni, z_w, '.k');
    ylim(ylimit)

    index = find(z_r > ylimit(1));
    t1 = text(ni+0.*z_r(index)-.15, z_r(index), num2cell(index), 'Color', 'r');

    dz = z_w(2:end)-z_w(1:end-1);
    t2 = text(ni+0.*z_r(index)+.1, z_r(index), cellstr(num2str(dz(index), '%.1f')), 'Color', 'b');
end

xlim([0 length(Ns)+1])
xlabel('Number of layers (m)')
ylabel('Depth (m)')
xticks(1:length(Ns))
xticklabels(num2cell(Ns))

set(gca, 'FontSize', 15)

title({['Depth = ', dstr, ' m \theta_s = ', num2str(theta_s), '    \theta_b = ', num2str(theta_b), '    hc = ', num2str(hc), ' m'], 'Red = Layer number, Blue = dz (m)'}, 'FontSize', 15)

print(['layers_N_depth_', dstr, 'm_theta_s_', num2str(theta_s), '_theta_b_', num2str(theta_b), '_hc_', num2str(hc), 'm'], '-dpng')