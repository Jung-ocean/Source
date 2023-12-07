% latitude 34.5

clear; clc; close all

season = 'winter';

g = grd('Lab');
filename_dye = ['dye_roms_ini.nc'];
nc = netcdf(filename_dye, 'w');

dye_01 = nc{'dye_01'}(:); dye_01 = dye_01.*0;
dye_02 = nc{'dye_02'}(:); dye_02 = dye_01.*0;
ot = nc{'ocean_time'}(:);

xq = [116 126.5 128 116 116];
yq = [34.5 34.5 42 42 34.5];

in = inpolygon(g.lon_rho, g.lat_rho, xq, yq);

switch season
    case 'winter'
        for i = 1:g.N
            dye_01(i,in) = 100;
        end
        
        ot = 0;
    case 'summer'
        for i = 1:g.N
            dye_02(i,in) = 100;
        end
        
        ot = ot-43200;
end

nc{'dye_01'}(:) = dye_01;
nc{'dye_02'}(:) = dye_02;
nc{'ocean_time'}(:) = ot;

close(nc)