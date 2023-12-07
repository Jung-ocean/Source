clear; clc

casename = 'NWP_ver40';
g = grd(casename);
z_w = g.z_w;

lat_target = 29;

lat = g.lat_rho(:,1);
dist = (lat - lat_target).^2;
index = find(dist == min(dist));

figure;
hold on

for i = 1:g.N+1
    plot(g.lon_rho(index,100:120), squeeze(z_w(i,index,100:120)), 'k')
end

saveas(gcf, ['layer_', casename, '.png'])