clear all; clc;

ndye = 1;

yyyy_all = 2023:2023;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

%filename_dye = ['roms_bndy_NP_GLORYS_', ystr, '.nc'];
%filename_dye = ['roms_NP_bry2_SODA-Y', ystr, '.nc'];
filename_dye = ['roms_NP_bry2_SODA-10Y_M.nc'];
dim_vert = 's_rho';

% Create a netCDF file
ncid = netcdf.open(filename_dye, 'NC_WRITE');
% Put open netCDF file into define mode
netcdf.reDef(ncid);
% Define a dimension
try
    dye_time_dimID = netcdf.defDim(ncid,'dye_time', 12);
catch
end
% Close open netCDF file
netcdf.close(ncid)

for i = 1:ndye
    
    dyenumber = num2char(i,2);
        
    % west
    nccreate(filename_dye, ['dye_west_',dyenumber], 'Dimensions', {'eta_rho',dim_vert,'dye_time'});
    ncwriteatt(filename_dye, ['dye_west_',dyenumber], 'long_name', 'dye concentration western boundary condition')
    ncwriteatt(filename_dye, ['dye_west_',dyenumber], 'units', 'kg meter-3')
    % east
    nccreate(filename_dye, ['dye_east_',dyenumber], 'Dimensions', {'eta_rho',dim_vert,'dye_time'});
    ncwriteatt(filename_dye, ['dye_east_',dyenumber], 'long_name', 'dye concentration eastern boundary condition')
    ncwriteatt(filename_dye, ['dye_east_',dyenumber], 'units', 'kg meter-3')
    % south
    nccreate(filename_dye, ['dye_south_',dyenumber], 'Dimensions', {'xi_rho',dim_vert,'dye_time'});
    ncwriteatt(filename_dye, ['dye_south_',dyenumber], 'long_name', 'dye concentration southern boundary condition')
    ncwriteatt(filename_dye, ['dye_south_',dyenumber], 'units', 'kg meter-3')
    % north
    nccreate(filename_dye, ['dye_north_',dyenumber], 'Dimensions', {'xi_rho',dim_vert,'dye_time'});
    ncwriteatt(filename_dye, ['dye_north_',dyenumber], 'long_name', 'dye concentration nothern boundary condition')
    ncwriteatt(filename_dye, ['dye_north_',dyenumber], 'units', 'kg meter-3')
    
end

nccreate(filename_dye, 'dye_time', 'Dimensions', {'dye_time', 12});
ncwriteatt(filename_dye, 'dye_time', 'long_name', 'time for dye boundary')
ncwriteatt(filename_dye, 'dye_time', 'units', 'day')
ncwriteatt(filename_dye, 'dye_time', 'cycle_length', double(365))

end