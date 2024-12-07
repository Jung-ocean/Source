clear; clc;

filename = 'grid_1D_DP.nc';

ncwrite(filename, 'spherical', 'F');

h = ncread(filename, 'h');
h = h.*0 + 100.0;
ncwrite(filename, 'h', h);

f = ncread(filename, 'f');
f = f.*0 + 1.2902e-04;
ncwrite(filename, 'f', f);

varis = {'lat_psi', 'lat_rho', 'lat_u', 'lat_v'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0 + 62.5;

    ncwrite(filename, vari, vari_tmp);
end

varis = {'lon_psi', 'lon_rho', 'lon_u', 'lon_v'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0 + (-177.5);

    ncwrite(filename, vari, vari_tmp);
end

varis = {'angle', 'diff_factor', 'visc_factor'};
for vi = 1:length(varis)
    vari = varis{vi};
    vari_tmp = ncread(filename, vari);
    vari_tmp = vari_tmp.*0;

    ncwrite(filename, vari, vari_tmp);
end