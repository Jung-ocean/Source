clear; clc

g = grd('Oregon_1km');
lon_rho = g.lon_rho;
lat_rho = g.lat_rho;
mask = g.mask_rho./g.mask_rho;

GMRT_file = '/data/jungjih/Models/DEM/GMRT/GMRTv4_4_1_20260411topo.grd';
lon_rho_GMRT = ncread(GMRT_file, 'lon');
lat_rho_GMRT = ncread(GMRT_file, 'lat');
altitude_GMRT = ncread(GMRT_file, 'altitude'); % positive upward

[lat_rho_GMRT2, lon_rho_GMRT2] = meshgrid(lat_rho_GMRT, lon_rho_GMRT);
Fbath = scatteredInterpolant(double(lon_rho_GMRT2(:)),double(lat_rho_GMRT2(:)),altitude_GMRT(:));
h=-Fbath(lon_rho,lat_rho); % original data is positive upward


figure;
set(gcf, 'Position', [1 200 1300 800])
t = tiledlayout(1,4);

ax1 = nexttile(1);
pcolor(lon_rho, lat_rho, -h.*mask); shading flat;
caxis([-200 0]);
colors = load('/home/server/pi/homes/jungjih/Source/Matlab/Tools/ncview/ncview_colormaps.mat');
color = colors.cm_hotres;
colormap(ax1, color)
c = colorbar;
c.Title.String = 'm';

ax2 = nexttile(2);
hdiff = g.h - h;
pcolor(lon_rho, lat_rho, hdiff.*mask); shading flat;
caxis([-20 20])
colormap(ax2, 'redblue')

ax3 = nexttile(3);
gl = grd('LiveOcean');
F = scatteredInterpolant(gl.lon_rho(:),gl.lat_rho(:),gl.h(:));
hinterp = F(lon_rho, lat_rho);
hdiff = hinterp - h;
pcolor(lon_rho, lat_rho, hdiff.*mask); shading flat;
caxis([-10 10])
colormap(ax3, 'redblue')

ax4 = nexttile(4);
gw = grd('WCOFS');
F = scatteredInterpolant(gw.lon_rho(:),gw.lat_rho(:),gw.h(:));
hinterp = F(lon_rho, lat_rho);
hdiff = hinterp - h;
pcolor(lon_rho, lat_rho, hdiff.*mask); shading flat;
caxis([-10 10])
colormap(ax4, 'redblue')

c = colorbar;
c.Title.String = 'm';