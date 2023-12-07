clear; clc; close all

g = grd('NP');

yyyy_all = 2011:2020;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

filename_dye = ['roms_river_NP_', ystr, '.nc'];
nc = netcdf(filename_dye, 'w');

river_dye_01 = nc{'river_dye_01'}(:); river_dye_01 = river_dye_01.*0;
%river_dye_02 = nc{'river_dye_02'}(:); river_dye_02 = river_dye_01.*0;

river_dye_01(:,g.N,13) = 100;
%river_dye_02(:,:,13) = 100;

nc{'river_dye_01'}(:) = river_dye_01;
%nc{'river_dye_02'}(:) = river_dye_02;

% Change river_Vshape
nc{'river_Vshape'}(:,13) = 0;
nc{'river_Vshape'}(g.N,13) = 1;

close(nc)
end