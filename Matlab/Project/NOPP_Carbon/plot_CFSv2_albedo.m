clear; clc; close all

model = 'Oregon_1km';
region = 'Oregon';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/General'])

yyyy = 2024;
ystr = num2str(yyyy);
mm = 9;
mstr = num2str(mm, '%02i');

swrad_down_str = 'DSWRF_surface';
swrad_up_str = 'USWRF_surface';
climit_down = [150 350];
climit_up = [0 30];
unit = 'W/m^2';

[lon_target, lat_target] = load_domain(region);

g = grd(model);

figure;
set(gcf, 'Position', [1 200 800 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';
title(t, {['CFSv2 ', ystr, mstr], ''}, 'FontSize', 20)

% Downward
[lon, lat, swrad_down] = load_CFSv2_monthly(yyyy, mm, swrad_down_str, lon_target, lat_target);
[lat2, lon2] = meshgrid(lat, lon);

ax1 = nexttile(1);
plot_map(region, 'mercator', 'l');
pe = pcolorm(lat2, lon2, swrad_down);
uistack(pe, 'bottom')
colormap(ax1, jet)
caxis(climit_down)
title('Downward', 'FontSize', 20)

c = colorbar;
c.Title.String = unit;
c.FontSize = 12;

% Upward
[lon, lat, swrad_up] = load_CFSv2_monthly(yyyy, mm, swrad_up_str, lon_target, lat_target);
[lat2, lon2] = meshgrid(lat, lon);

ax2 = nexttile(2);
plot_map(region, 'mercator', 'l');
pc = pcolorm(lat2, lon2, swrad_up);
uistack(pc, 'bottom')
colormap(ax2, jet)
caxis(climit_up)
title('Upward', 'FontSize', 20)

plabel('off')

c = colorbar;
c.Title.String = unit;
c.FontSize = 12;

% Albedo
albedo = swrad_up./swrad_down;
ax3 = nexttile(3);
plot_map(region, 'mercator', 'l');
pr = pcolorm(g.lat_rho, g.lon_rho, albedo);
uistack(pr, 'bottom')
colormap(ax3, jet(20))
caxis([0 0.2])
title('Albedo', 'FontSize', 20)

plabel('off')

c = colorbar;
c.FontSize = 12;

pause(3)

print(['CFSv2_albedo', ystr, mstr], '-dpng')