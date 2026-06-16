clear; clc

region = 'US_west_NANOOS';

gl = grd('LiveOcean');
dx = 1./gl.pm;
dy = 1./gl.pn;

g = grd('Oregon_1km');
min_lon = min(g.lon_rho(:));
max_lon = max(g.lon_rho(:));
min_lat = min(g.lat_rho(:));
max_lat = max(g.lat_rho(:));

figure;
set(gcf, 'Position', [1 200 800 600])
t = tiledlayout(1,2);
t.Padding = 'compact';
t.TileSpacing = 'tight';

nexttile(1);
plot_map(region, 'mercator', 'l');
contourm(gl.lat_rho, gl.lon_rho, gl.h, [200 200], 'k');
p = pcolorm(gl.lat_rho, gl.lon_rho, dx);
uistack(p, 'bottom')
colormap(jet(6))
caxis([0 3000]);
title('dx', 'FontSize', 15)

plotm([min_lat min_lat max_lat max_lat min_lat], [max_lon min_lon min_lon max_lon max_lon], '-k', 'LineWidth', 3)

nexttile(2);
plot_map(region, 'mercator', 'l');
contourm(gl.lat_rho, gl.lon_rho, gl.h, [200 200], 'k');
p = pcolorm(gl.lat_rho, gl.lon_rho, dy);
uistack(p, 'bottom')
colormap(jet(6))
caxis([0 3000]);
c = colorbar;
c.Title.String = 'm';
plabel('off')
title('dy', 'FontSize', 15)

plotm([min_lat min_lat max_lat max_lat min_lat], [max_lon min_lon min_lon max_lon max_lon], '-k', 'LineWidth', 3)

print('LiveOcean_dxdy', '-dpng')