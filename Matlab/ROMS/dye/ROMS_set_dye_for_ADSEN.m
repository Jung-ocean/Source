% North of latitude 34.5; same xq, and yq = [34.5 34.5 42 42 34.5];
% North of latitude 33

clear; clc; close all

yyyy_all = 2013:2013;

g = grd('upwelling5km_flat');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    filename_dye = ['avg_0015_dye.nc'];
    nc = netcdf(filename_dye, 'w');
    dye_01 = nc{'dye_01'}(:); dye_01 = dye_01.*0;
    dye_01(30,15:25,60:70) = 1;
    
    ot = 0;
    
    nc{'dye_01'}(:) = dye_01;
    nc{'ocean_time'}(:) = ot;
    
    close(nc)
end