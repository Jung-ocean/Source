function create_HYCOM_nc(fname, size_3d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Create empty HYCOM NetCDF file for monthly data
%
%       create_HYCOM_nc(fname, [Depth, Lat, Lon])
%       Fname: Output file name
%       Example) create_HYCOM_nc(myncfile.nc, [20, 488, 386])
%
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = size_3d(1);
n = size_3d(2);
m = size_3d(3);

% Generate NetCDF file
ncid = netcdf.create(fname, 'clobber');

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','HYCOM monthly mean');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));

% Dimensions
time_dimID = netcdf.defDim(ncid, 'time', 1);
depth_dimID = netcdf.defDim(ncid,'depth', s);
lat_dimID = netcdf.defDim(ncid,'latitude', n);
lon_dimID = netcdf.defDim(ncid,'longitude', m);

% Attributes associated with the variable
depth_ID = netcdf.defVar(ncid, 'depth', 'double', depth_dimID);
netcdf.putAtt(ncid, depth_ID, 'standard_name', 'depth');
netcdf.putAtt(ncid, depth_ID, 'units', 'm');
netcdf.putAtt(ncid, depth_ID, 'positive', 'down');
netcdf.putAtt(ncid, depth_ID, 'axis', 'Z');

time_ID = netcdf.defVar(ncid, 'time', 'double', time_dimID);
netcdf.putAtt(ncid, time_ID, 'long_name', 'time');
netcdf.putAtt(ncid, time_ID, 'units', 'days since 1900-12-31 00:00:00');

lon_ID = netcdf.defVar(ncid, 'longitude', 'double', [lon_dimID lat_dimID]);
netcdf.putAtt(ncid, lon_ID, 'standard_name', 'longitude');
netcdf.putAtt(ncid, lon_ID, 'units', 'degrees_east');

lat_ID = netcdf.defVar(ncid, 'latitude', 'double', [lon_dimID lat_dimID]);
netcdf.putAtt(ncid, lat_ID, 'standard_name', 'latitude');
netcdf.putAtt(ncid, lat_ID, 'units', 'degrees_north');

% Sea surface height
var_ID = netcdf.defVar(ncid, 'ssh', 'double', [lon_dimID lat_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Sea Surface Height');
netcdf.putAtt(ncid, var_ID, 'units', 'm');

% Temperature
var_ID = netcdf.defVar(ncid, 'temp', 'double', [lon_dimID lat_dimID depth_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Temperature');
netcdf.putAtt(ncid, var_ID, 'units', 'Celsius');

% Salinity
var_ID = netcdf.defVar(ncid, 'salt', 'double', [lon_dimID lat_dimID depth_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Salinity');
netcdf.putAtt(ncid, var_ID, 'units', 'psu');

% U
var_ID = netcdf.defVar(ncid, 'u', 'double', [lon_dimID lat_dimID depth_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Zonal Velocity');
netcdf.putAtt(ncid, var_ID, 'units', 'm/s');

% V
var_ID = netcdf.defVar(ncid, 'v', 'double', [lon_dimID lat_dimID depth_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'long_name', 'Meridional Velocity');
netcdf.putAtt(ncid, var_ID, 'units', 'm/s');

netcdf.endDef(ncid);

netcdf.close(ncid);