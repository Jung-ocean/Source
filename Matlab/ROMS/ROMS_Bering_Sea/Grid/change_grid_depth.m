clear; clc; close all

h = ncread('BeringSea_DsmV2_grid_Ndeep.nc', 'h')';
g = grd('BSf');

figure; 
pcolor(g.lon_rho, g.lat_rho, h.*g.mask_rho./g.mask_rho)
shading interp
caxis([5 20])
colorbar
xlim([-172 -166])
ylim([65 66.5])

p = drawpolygon;

[in, on] = inpolygon(g.lon_rho, g.lat_rho, p.Position(:,1), p.Position(:,2));
mask = in./in;
hold on;
pcolor(g.lon_rho, g.lat_rho, mask)

h_part = h(in);
h_part(h_part < 15) = 15;
h(in) = h_part;

figure; 
pcolor(g.lon_rho, g.lat_rho, h.*g.mask_rho./g.mask_rho)
shading interp
caxis([5 20])
colorbar
xlim([-172 -166])
ylim([65 66.5])

ncwrite('BeringSea_DsmV2_grid_Ndeep.nc', 'h', h')