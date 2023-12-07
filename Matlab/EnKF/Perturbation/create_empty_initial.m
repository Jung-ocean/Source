function create_empty_initial(fname, size_rho)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       
%       Create empty ROMS initial file
%
%       create_empty_initial(fname, [s_rho, eta_rho, xi_rho])       
%       Fname: File name
%       Size_rho: Size of Rho variable: [S_rho Eta Xi]
%       Example) create_empty_initial(myncfile.nc, [20, 488, 386])
%       
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Empty initial file is ',fname])
s = size_rho(1);
n = size_rho(2);
m = size_rho(3);

% Generate NetCDF file
ncid = netcdf.create(fname, 'clobber');

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','ROMS initial File');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));

% Dimensions
xi_rho_dimID = netcdf.defDim(ncid,'xi_rho', m);
eta_rho_dimID = netcdf.defDim(ncid,'eta_rho', n);
xi_u_dimID = netcdf.defDim(ncid,'xi_u', m - 1);
eta_u_dimID = netcdf.defDim(ncid,'eta_u', n);
xi_v_dimID = netcdf.defDim(ncid,'xi_v', m);
eta_v_dimID = netcdf.defDim(ncid,'eta_v', n - 1);
xi_psi_dimID = netcdf.defDim(ncid,'xi_psi', m - 1);
eta_psi_dimID = netcdf.defDim(ncid,'eta_psi', n - 1);
s_w_dimID = netcdf.defDim(ncid,'s_w', s + 1);
s_rho_dimID = netcdf.defDim(ncid,'s_rho', s);
time_dimID = netcdf.defDim(ncid, 'ocean_time', 1);

% Attributes associated with the variable
time_ID = netcdf.defVar(ncid, 'ocean_time', 'double', time_dimID);
netcdf.putAtt(ncid, time_ID, 'long_name', 'Julian days from ref_year');
netcdf.putAtt(ncid, time_ID, 'units', 'Julian days');

lon_ID = netcdf.defVar(ncid, 'lon_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, lon_ID, 'long_name', 'x location of RHO-points');
netcdf.putAtt(ncid, lon_ID, 'units', 'degree');

lat_ID = netcdf.defVar(ncid, 'lat_rho', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, lat_ID, 'long_name', 'y location of RHO-points');
netcdf.putAtt(ncid, lat_ID, 'units', 'degree');

% Temperature
var_ID = netcdf.defVar(ncid, 'temp', 'double', [xi_rho_dimID eta_rho_dimID s_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Temperature');
netcdf.putAtt(ncid, var_ID, 'units', 'Celsius');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time s_rho lat_rho lon_rho');
netcdf.putAtt(ncid, var_ID, 'field', 'temperature, scalar, series');

% Salinity
var_ID = netcdf.defVar(ncid, 'salt', 'double', [xi_rho_dimID eta_rho_dimID s_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Salinity');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time s_rho lat_rho lon_rho');
netcdf.putAtt(ncid, var_ID, 'field', 'salinity, scalar, series');

% Zeta
var_ID = netcdf.defVar(ncid, 'zeta', 'double', [xi_rho_dimID eta_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Free-surface');
netcdf.putAtt(ncid, var_ID, 'units', 'meter');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time lat_rho lon_rho');
netcdf.putAtt(ncid, var_ID, 'field', 'free-surface, scalar, series');

% Ubar
var_ID = netcdf.defVar(ncid, 'ubar', 'double', [xi_u_dimID eta_u_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Vertically integrated u-momentum component');
netcdf.putAtt(ncid, var_ID, 'units', 'meter second-1');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time lat_rho lon_rho');
netcdf.putAtt(ncid, var_ID, 'field', 'ubar-velocity, scalar, series');

% Vbar
var_ID = netcdf.defVar(ncid, 'vbar', 'double', [xi_v_dimID eta_v_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Vertically integrated v-momentum component');
netcdf.putAtt(ncid, var_ID, 'units', 'meter second-1');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time lat_rho lon_rho');
netcdf.putAtt(ncid, var_ID, 'field', 'vbar-velocity, scalar, series');

% U
var_ID = netcdf.defVar(ncid, 'u', 'double', [xi_u_dimID eta_u_dimID s_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'U-momentum component');
netcdf.putAtt(ncid, var_ID, 'units', 'meter second-1');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time s_rho lat_u lon_u');
netcdf.putAtt(ncid, var_ID, 'field', 'u-velocity, scalar, series');

% V
var_ID = netcdf.defVar(ncid, 'v', 'double', [xi_v_dimID eta_v_dimID s_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'V-momentum component');
netcdf.putAtt(ncid, var_ID, 'units', 'meter second-1');
netcdf.putAtt(ncid, var_ID, 'time', 'ocean_time');
netcdf.putAtt(ncid, var_ID, 'coordinates', 'ocean_time s_rho lat_v lon_v');
netcdf.putAtt(ncid, var_ID, 'field', 'v-velocity, scalar, series');

netcdf.endDef(ncid);

% Write ocean_time(0, initial) to variable
netcdf.putVar(ncid, time_ID, 0);

netcdf.close(ncid);