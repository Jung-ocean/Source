clear; clc;

filename = 'grid_1D_DP.nc';

ncwrite(filename, 'spherical', 'F');

h = ncread(filename, 'h');
h = h.*0 + mean(h(:));
ncwrite(filename, 'h', h);

f = ncread(filename, 'f');
f = f.*0 + mean(f(:));
ncwrite(filename, 'f', f);

% set pm to pn
pn = ncread(filename, 'pn');
pm = pn;
ncwrite(filename, 'pm', pm);

varis = {'lat_psi', 'lat_rho', 'lat_u', 'lat_v'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0 + mean(vari_tmp(:));

    ncwrite(filename, vari, vari_tmp);
end

varis = {'lon_psi', 'lon_rho', 'lon_u', 'lon_v'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0 + mean(vari_tmp(:));

    ncwrite(filename, vari, vari_tmp);
end

varis = {'angle', 'diff_factor', 'visc_factor'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0;

    ncwrite(filename, vari, vari_tmp);
end

lon_rho = ncread(filename, 'lon_rho');
lon_rho = mean(lon_rho(:));
lat_rho = ncread(filename, 'lat_rho');
lat_rho = mean(lat_rho(:));

g = grd('BSf');
figure;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], '-k');
plotm(lat_rho, lon_rho, '.r', 'MarkerSize', 25);

print('point', '-dpng')