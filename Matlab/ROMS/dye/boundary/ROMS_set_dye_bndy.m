clear; clc; close all

yyyy_all = 2023:2023;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

%filename_dye = ['roms_bndy_NP_GLORYS_', ystr, '.nc'];
%filename_dye = ['roms_NP_bry2_SODA-Y', ystr, '.nc'];
filename_dye = ['roms_NP_bry2_SODA-10Y_M.nc'];
nc = netcdf(filename_dye, 'w');

nc{'dye_west_01'}(:) = nc{'dye_west_01'}(:).*0;
nc{'dye_east_01'}(:) = nc{'dye_east_01'}(:).*0;
nc{'dye_south_01'}(:) = nc{'dye_south_01'}(:).*0;
nc{'dye_north_01'}(:) = nc{'dye_north_01'}(:).*0;

% nc{'dye_west_02'}(:) = nc{'dye_west_02'}(:).*0;
% nc{'dye_east_02'}(:) = nc{'dye_east_02'}(:).*0;
% nc{'dye_south_02'}(:) = nc{'dye_south_02'}(:).*0;
% nc{'dye_north_02'}(:) = nc{'dye_north_02'}(:).*0;

% nc{'dye_west_03'}(:) = nc{'dye_west_03'}(:).*0;
% nc{'dye_east_03'}(:) = nc{'dye_east_03'}(:).*0;
% nc{'dye_south_03'}(:) = nc{'dye_south_03'}(:).*0;
% nc{'dye_north_03'}(:) = nc{'dye_north_03'}(:).*0;

nc{'dye_time'}(:) = [15:30:365];

close(nc)

end