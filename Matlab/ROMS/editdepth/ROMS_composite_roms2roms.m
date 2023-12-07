clear; clc

%lon_lim = [122 130]; lat_lim = [25 32];
%lon_lim = [140 145]; lat_lim = [44 46.5];
%lon_lim = [121 122.3]; lat_lim = [22 25];
%lon_lim = [122 131]; lat_lim = [25 33];
%lon_lim = [120 131]; lat_lim = [24 34];
%lon_lim = [120 124]; lat_lim = [20 25];
%lon_lim = [120 124]; lat_lim = [18 25];
lon_lim = [120.5 122.2]; lat_lim = [18 21];

g = grd('test');
%copyfile(g.grd_file,'test.nc')

[lon_ind_model, lat_ind_model] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);
grid_lon = g.lon_rho(lat_ind_model, lon_ind_model);
grid_lat = g.lat_rho(lat_ind_model, lon_ind_model);

tnc = netcdf('test.nc', 'w');
h = tnc{'h'}(:);

gl = grd('NWP_ver7');
h(lat_ind_model, lon_ind_model) = gl.h(lat_ind_model, lon_ind_model);

h_new_smooth = smoothgrid(h, g.mask_rho, 7, 5000, 5000, 1, 2 ,1);

%h(lat_ind_smooth, lon_ind_smooth) = h_new_smooth;
%figure; pcolor(h.*g.mask_rho./g.mask_rho); shading flat

tnc{'h'}(:) = h_new_smooth;
close(tnc)