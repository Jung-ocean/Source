%-----------------------------------------------------------
%  Create empty river data NetCDF file
%
%   Called from latte_rivers.m
%-----------------------------------------------------------

disp('  ')
disp(['The RIVER netcdf file will be ' Fname])
disp('  ')

ncid = netcdf.create(Fname, 'clobber');

varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'out_file', Fname);
netcdf.putAtt(ncid,varid,'grd_file', grd_file);
netcdf.putAtt(ncid,varid,'source', Rname);
netcdf.putAtt(ncid,varid,'details', detailstr);
netcdf.putAtt(ncid,varid,'history', ['Created by ' which(mfilename) ' - ' datestr(now)]);

% dimensions

eta_rho = size(g.lon_rho,1);
xi_rho = size(g.lon_rho,2);
eta_u = size(g.lon_u,1);
xi_u = size(g.lon_u,2);
eta_v = size(g.lon_v,1);
xi_v = size(g.lon_v,2);
r_time = length(River.time);
r_time_units = River.time_units;
s_rho = N;
river = r;

xi_u_dimID = netcdf.defDim(ncid, 'xi_u', xi_u);
xi_v_dimID = netcdf.defDim(ncid, 'xi_v', xi_v);
xi_rho_dimID = netcdf.defDim(ncid, 'xi_rho', xi_rho);
eta_u_dimID = netcdf.defDim(ncid, 'eta_u', eta_u);
eta_v_dimID = netcdf.defDim(ncid, 'eta_v', eta_v);
eta_rho_dimID = netcdf.defDim(ncid, 'eta_rho', eta_rho);
s_rho_dimID = netcdf.defDim(ncid, 's_rho', s_rho);
river_dimID = netcdf.defDim(ncid, 'river', river);
river_name_dimID = netcdf.defDim(ncid, 'river_name', 15);
time_dimID = netcdf.defDim(ncid, 'river_time', r_time); % UNLIMITED

% the variables

var_ID = netcdf.defVar(ncid, 'river', 'float', river_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river identification number');
netcdf.putAtt(ncid, var_ID, 'units', 'non-dimensional');
netcdf.putAtt(ncid, var_ID, 'field', 'river, scalar');

var_ID = netcdf.defVar(ncid, 'river_name', 'char', [river_name_dimID river_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river name');

var_ID = netcdf.defVar(ncid, 'river_Xposition', 'float', river_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river XI-position at RHO points');
netcdf.putAtt(ncid, var_ID, 'units', 'non-dimensional');
netcdf.putAtt(ncid, var_ID, 'valid_min', 1);
netcdf.putAtt(ncid, var_ID, 'valid_max', xi_u);
netcdf.putAtt(ncid, var_ID, 'field', 'river_Xposition, scalar');

var_ID = netcdf.defVar(ncid, 'river_Eposition', 'float', river_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river ETA-position at RHO points');
netcdf.putAtt(ncid, var_ID, 'units', 'non-dimensional');
netcdf.putAtt(ncid, var_ID, 'valid_min', 1);
netcdf.putAtt(ncid, var_ID, 'valid_max', eta_v);
netcdf.putAtt(ncid, var_ID, 'field', 'river_Eposition, scalar');

var_ID = netcdf.defVar(ncid, 'river_direction', 'float', river_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff direction');
netcdf.putAtt(ncid, var_ID, 'units', 'non-dimensional');
netcdf.putAtt(ncid, var_ID, 'field', 'river_direction, scalar');

var_ID = netcdf.defVar(ncid, 'river_flag', 'float', river_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff tracer flag');
netcdf.putAtt(ncid, var_ID, 'option_0', 'all tracers are off');
netcdf.putAtt(ncid, var_ID, 'option_1', 'only temperature is on');
netcdf.putAtt(ncid, var_ID, 'option_2', 'only salinity is on');
netcdf.putAtt(ncid, var_ID, 'option_3', 'both temperature and salinity are on');
netcdf.putAtt(ncid, var_ID, 'field', 'river_direction, scalar');
netcdf.putAtt(ncid, var_ID, 'units', 'non-dimensional');
netcdf.putAtt(ncid, var_ID, 'field', 'river_flag, scalar');

var_ID = netcdf.defVar(ncid, 'river_Vshape', 'float', [river_dimID s_rho_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff mass tranport vertical profile');
netcdf.putAtt(ncid, var_ID, 'units', 'nondimensional');
netcdf.putAtt(ncid, var_ID, 'field', 'river_Vshape, scalar');

var_ID = netcdf.defVar(ncid, 'river_time', 'float', time_dimID);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river day of year');
netcdf.putAtt(ncid, var_ID, 'units', r_time_units);
netcdf.putAtt(ncid, var_ID, 'cycle_length', 360.00);
%netcdf.putAtt(ncid, var_ID, 'cycle_length', 365.25);
netcdf.putAtt(ncid, var_ID, 'field', 'river_time, scalar, series');

var_ID = netcdf.defVar(ncid, 'river_transport', 'float', [river_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff volume transport');
netcdf.putAtt(ncid, var_ID, 'units', 'meter^3 / sec');
netcdf.putAtt(ncid, var_ID, 'field', 'river_transport, scalar, series');
netcdf.putAtt(ncid, var_ID, 'time', 'river_time');

var_ID = netcdf.defVar(ncid, 'river_temp', 'float', [river_dimID s_rho_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff potential temperature');
netcdf.putAtt(ncid, var_ID, 'units', 'Celsius');
netcdf.putAtt(ncid, var_ID, 'field', 'river_temp, scalar, series');
netcdf.putAtt(ncid, var_ID, 'time', 'river_time');

var_ID = netcdf.defVar(ncid, 'river_salt', 'float', [river_dimID s_rho_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'river runoff salinity');
netcdf.putAtt(ncid, var_ID, 'units', 'PSU');
netcdf.putAtt(ncid, var_ID, 'field', 'river_salt, scalar, series');
netcdf.putAtt(ncid, var_ID, 'time', 'river_time');

netcdf.endDef(ncid);
netcdf.close(ncid);

