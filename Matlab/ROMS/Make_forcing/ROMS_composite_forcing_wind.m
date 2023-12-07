clear; clc

g = grd('NWP');
vari = 'Vwind';

[lon_lim, lat_lim] = domain_J('windstress_southern');
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);

ot_start = datenum(2013,7,1) - datenum(2013,1,1);
ot_end = datenum(2013,9,1) - datenum(2013,1,1);

filepath = 'G:\Model\ROMS\Case\NWP\input\';
filename_ori = [vari, '_NWP_ECMWF_2013.nc'];

copyfile([filepath, filename_ori], ['.\new_', filename_ori])

nc = netcdf(['new_', filename_ori], 'w');
varitime = nc{[vari, '_time']}(:);

index_start = find(varitime == ot_start);
index_end = find(varitime == ot_end);

%==========================================================================
ot_start = datenum(2012,7,1) - datenum(2012,1,1);
ot_end = datenum(2012,9,1) - datenum(2012,1,1);

nc_new = netcdf([filepath, vari, '_NWP_ECMWF_2012.nc']);
varitime_new = nc_new{[vari, '_time']}(:);

index_start_new = find(varitime_new == ot_start);
index_end_new = find(varitime_new == ot_end);

vari_new = nc_new{vari}(index_start_new:index_end_new, lat_ind, lon_ind);
%==========================================================================

nc{vari}(index_start:index_end, lat_ind, lon_ind) = vari_new;

close(nc)
close(nc_new)