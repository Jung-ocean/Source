clear; clc

filename = 'roms_grd_auto_rdrg2_depth.nc';

nc = netcdf(filename, 'w');
lon_rho = nc{'lon_rho'}(:);
lat_rho = nc{'lat_rho'}(:);
mask_rho = nc{'mask_rho'}(:);
h = nc{'h'}(:);
rdrag2 = nc{'rdrag2'}(:);

%kappa = .4;
%z0 = 1e-5;
%rdrag2 = kappa.^2./(log(h./z0) - 1).^2

rdrag2_max = 3e-3;
href = min(min(h))-1;

rdrag2 = rdrag2_max./sqrt(h - href);

nc{'rdrag2'}(:) = rdrag2;
close(nc)

figure; pcolor(lon_rho, lat_rho, rdrag2.*mask_rho./mask_rho); shading flat