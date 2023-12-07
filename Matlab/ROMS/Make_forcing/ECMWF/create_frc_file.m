function create_frc_file(fname,varname,var,tframe,cycle)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Create ROMS forcing file
%
%       create_frc_file(fname,varname,var,tframe,cycle)
%       fname: file name
%       varname: variable name
%       var: variable
%       tframe: ocean time
%       cycle: cycle length
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['file is ',fname])
[t,n,m] = size(var);
var_time = [varname,'_time'];

% Generate NetCDF file
ncid = netcdf.create(fname, 'clobber');

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','ROMS Forcing File');
netcdf.putAtt(ncid,varid,'title','Bulk Formular Forcing File');
netcdf.putAtt(ncid,varid,'source','ECMWF Interim Data (105E-165E, 9N-55.5N)');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));

% Dimensions
eta_dimID = netcdf.defDim(ncid,'eta_rho', n);
xi_dimID = netcdf.defDim(ncid,'xi_rho', m);
time_dimID = netcdf.defDim(ncid, var_time, t);

% Attributes associated with the variable
time_ID = netcdf.defVar(ncid, var_time, 'double', time_dimID);
netcdf.putAtt(ncid, time_ID, 'long_name', 'Julian days from ref_year');
netcdf.putAtt(ncid, time_ID, 'units', 'Julian days');
netcdf.putAtt(ncid, time_ID, 'cycle_length', cycle);

lon_ID = netcdf.defVar(ncid, 'lon_rho', 'double', [xi_dimID eta_dimID]);
netcdf.putAtt(ncid, lon_ID, 'long_name', 'x location of RHO-points');
netcdf.putAtt(ncid, lon_ID, 'units', 'degree');

lat_ID = netcdf.defVar(ncid, 'lat_rho', 'double', [xi_dimID eta_dimID]);
netcdf.putAtt(ncid, lat_ID, 'long_name', 'y location of RHO-points');
netcdf.putAtt(ncid, lat_ID, 'units', 'degree');

switch varname
    case 'swrad'
        var_ID = netcdf.defVar(ncid, 'swrad', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF - net short wave Radiation');
        netcdf.putAtt(ncid, var_ID, 'units', 'W/m^2');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'swflux'
        var_ID = netcdf.defVar(ncid, 'swflux', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'surface freshwater flux (E-P)');
        netcdf.putAtt(ncid, var_ID, 'units', 'centimeter day-1');
        netcdf.putAtt(ncid, var_ID, 'positive', 'net evaporation');
        netcdf.putAtt(ncid, var_ID, 'negative', 'net precipitation');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Pair'
        var_ID = netcdf.defVar(ncid, 'Pair', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF sea level air pressure');
        netcdf.putAtt(ncid, var_ID, 'units', 'mbar');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Uwind'
        var_ID = netcdf.defVar(ncid, 'Uwind', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF 10 m U');
        netcdf.putAtt(ncid, var_ID, 'units', 'm/s');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Vwind'
        var_ID = netcdf.defVar(ncid, 'Vwind', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF 10 m V');
        netcdf.putAtt(ncid, var_ID, 'units', 'm/s');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Tair'
        var_ID = netcdf.defVar(ncid, 'Tair', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF 2 m Temperature');
        netcdf.putAtt(ncid, var_ID, 'units', 'Celsius');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Qair'
        var_ID = netcdf.defVar(ncid, 'Qair', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF Relative Humidity');
        netcdf.putAtt(ncid, var_ID, 'units', 'Percentage');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'Dair'
        var_ID = netcdf.defVar(ncid, 'Dair', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF 2 m Dewpoint Temperature');
        netcdf.putAtt(ncid, var_ID, 'units', 'Celsius');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
        
    case 'rain'
        var_ID = netcdf.defVar(ncid, 'rain', 'double', [xi_dimID eta_dimID time_dimID]);
        netcdf.putAtt(ncid, var_ID, 'long_name', 'ECMWF Precipitation Rate');
        netcdf.putAtt(ncid, var_ID, 'units', 'kg/m^2s');
        netcdf.putAtt(ncid, var_ID, 'time', var_time);
end
netcdf.endDef(ncid);

% Write data to variable
netcdf.putVar(ncid, time_ID, tframe);
%netcdf.putVar(ncid, lon_ID, lon_rho);
%netcdf.putVar(ncid, lat_ID, lat_rho);
var_permute = permute(var, [3,2,1]);
netcdf.putVar(ncid, var_ID, var_permute);

netcdf.close(ncid);