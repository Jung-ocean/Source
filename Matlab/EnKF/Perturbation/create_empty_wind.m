function create_empty_wind(fname, size_wind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       
%       Create empty ECMWF wind file
%
%       create_empty_wind(fname, [time, lat, lon])       
%       Fname: File name
%       Size_wind: Size of wind variable: [time lat lon]
%       Example) create_empty_initial(myncfile.nc, [4018 32 41])
%       
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['Empty wind file is ',fname])
len_time = size_wind(1);
len_lat = size_wind(2);
len_lon = size_wind(3);

% Generate NetCDF file
ncid = netcdf.create(fname, 'clobber');

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','ECMWF forcing File');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));

% Dimensions
lon_dimID = netcdf.defDim(ncid,'longitude', len_lon);
lat_dimID = netcdf.defDim(ncid,'latitude', len_lat);
time_dimID = netcdf.defDim(ncid,'time', len_time);

% Attributes associated with the variable
% Longitude
lon_ID = netcdf.defVar(ncid, 'longitude', 'double', [lon_dimID]);
netcdf.putAtt(ncid, lon_ID, 'units', 'degrees_east');
netcdf.putAtt(ncid, lon_ID, 'long_name', 'longitude');

% Latitude
lat_ID = netcdf.defVar(ncid, 'latitude', 'double', [lat_dimID]);
netcdf.putAtt(ncid, lat_ID, 'units', 'degrees_north');
netcdf.putAtt(ncid, lat_ID, 'long_name', 'latitude');

% Time
time_ID = netcdf.defVar(ncid, 'time', 'double', [time_dimID]);
netcdf.putAtt(ncid, time_ID, 'units', 'hours since 1900-01-01 00:00:0.0');
netcdf.putAtt(ncid, time_ID, 'long_name', 'time');
netcdf.putAtt(ncid, time_ID, 'calendar', 'gregorian');

% U
var_ID = netcdf.defVar(ncid, 'u10', 'double', [lon_dimID lat_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'units', 'm s**-1');
netcdf.putAtt(ncid, var_ID, 'long_name', '10 metre U wind component');

% V
var_ID = netcdf.defVar(ncid, 'v10', 'double', [lon_dimID lat_dimID time_dimID]);
netcdf.putAtt(ncid, var_ID, 'units', 'm s**-1');
netcdf.putAtt(ncid, var_ID, 'long_name', '10 metre V wind component');

netcdf.endDef(ncid);

netcdf.close(ncid);