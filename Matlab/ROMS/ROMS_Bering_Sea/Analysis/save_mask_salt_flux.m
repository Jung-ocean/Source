clear; clc; close all

g = grd('BSf');

mask_shelf = g.mask_rho;
mask_basin = g.mask_rho;
h = g.h;
lat = g.lat_rho;
lon = g.lon_rho;

mask_shelf = mask_shelf.*0;
index = find(h <= 200);
mask_shelf(index) = 1;
index = find(lon < -189.4);
mask_shelf(index) = 0;
index = find(lat < 54.72);
mask_shelf(index) = 0;
load polygon_outside.mat
[in, on] = inpolygon(g.lon_rho, g.lat_rho, p.Position(:,1), p.Position(:,2));
mask_shelf(in) = 0;
mask_shelf = mask_shelf.*g.mask_rho;

figure; hold on;
pcolor(g.lon_rho, g.lat_rho, mask_shelf.*g.mask_rho./g.mask_rho); shading flat
caxis([0 1])
contour(g.lon_rho, g.lat_rho, h, [50 100 200 1000], 'k')
print('mask_shelf', '-dpng')

mask_basin = mask_basin.*0;
index = find(h > 200);
mask_basin(index) = 1;
mask_basin = mask_basin.*g.mask_rho;

figure; hold on;
pcolor(g.lon_rho, g.lat_rho, mask_basin.*g.mask_rho./g.mask_rho); shading flat
caxis([0 1])
contour(g.lon_rho, g.lat_rho, h, [50 100 200 1000], 'k')
print('mask_basin', '-dpng')

save mask_shelf_basin.mat mask_shelf mask_basin