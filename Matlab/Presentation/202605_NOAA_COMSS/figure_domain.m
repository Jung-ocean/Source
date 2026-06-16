clear; clc; close all

g = grd('BSf');

figure; hold on; grid on;

% Entire domain
set(gcf, 'Position', [1 200 800 800])

subplot('Position',[.1,.65,.8,.3]); hold on;
plot_map('Bering', 'mercator', 'l')
text(-0.5, 1.57, 'a', 'FontSize', 20)
mlabel('FontSize', 12);
plabel('FontSize', 12);

pcolorm(g.lat_rho, g.lon_rho, g.h.*g.mask_rho./g.mask_rho);
colormap depth
c = colorbar;
c.Title.String = 'm';
c.FontSize = 12;
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k')

plot_map('Bering', 'mercator', 'l')
mlabel('FontSize', 12);
plabel('FontSize', 12);

[lon, lat] = load_domain('Gulf_of_Anadyr');
plotm([lat(1) lat(1) lat(2) lat(2) lat(1)], [lon(1) lon(2) lon(2) lon(1) lon(1)], '-r', 'LineWidth', 2)

exportgraphics(gcf,'domain.tif','Resolution',300) 