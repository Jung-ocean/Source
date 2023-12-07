function nc_data_obs(fname, len)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Create an empty netcdf frc file
%       x: total number of rho points in x direction
%       y: total number of rho points in y direction
%       varname: name of field variable
%       fname: name of the ecmwf file
%       var: variable of ecmwf file
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ncid = netcdf.create(fname, 'clobber');
disp(['xt_i is ',num2str(len)])

% Global Attributes
varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','Observation for data assimilation');
netcdf.putAtt(ncid,varid,'title','Observed Temperature');
netcdf.putAtt(ncid,varid,'source','Observation');
netcdf.putAtt(ncid,varid,'author','Created by Jihun Jung');
netcdf.putAtt(ncid,varid,'date',datestr(date, 'yyyymmdd'));

% Dimensions
xt_i_dimID = netcdf.defDim(ncid,'xt_i', len);
time_dimID = netcdf.defDim(ncid,'time', 1);

% Attributes associated with the variable
ixt_ID = netcdf.defVar(ncid, 'ixt', 'double', xt_i_dimID);
netcdf.putAtt(ncid, ixt_ID, 'long_name', 'Number of the data');
netcdf.putAtt(ncid, ixt_ID, 'units', 'degree');

rlon_ID = netcdf.defVar(ncid, 'rlon', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, rlon_ID, 'long_name', 'Longitude');
netcdf.putAtt(ncid, rlon_ID, 'units', 'degree_E');

rlat_ID = netcdf.defVar(ncid, 'rlat', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, rlat_ID, 'long_name', 'Latitude');
netcdf.putAtt(ncid, rlat_ID, 'units', 'degree_N');

rdepth_ID = netcdf.defVar(ncid, 'rdepth', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, rdepth_ID, 'long_name', 'Depth');
netcdf.putAtt(ncid, rdepth_ID, 'units', 'm');

obsdata_ID = netcdf.defVar(ncid, 'obsdata', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, obsdata_ID, 'long_name', 'Observed data');
netcdf.putAtt(ncid, obsdata_ID, 'units', 'deg C or psu or m');

obserr_ID = netcdf.defVar(ncid, 'obserr', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, obserr_ID, 'long_name', 'Observation error');
netcdf.putAtt(ncid, obserr_ID, 'units', 'ssh: 0.05, temp: 0.1-0.8');

dindex_ID = netcdf.defVar(ncid, 'dindex', 'double', [xt_i_dimID time_dimID]);
netcdf.putAtt(ncid, dindex_ID, 'long_name', 'data index');
netcdf.putAtt(ncid, dindex_ID, 'units', '1: zeta, 2: temp, 3: salt, 4: u, 5: v');

ndata_ID = netcdf.defVar(ncid, 'ndata', 'double', time_dimID);
netcdf.putAtt(ncid, ndata_ID, 'long_name', 'the number of data');
netcdf.putAtt(ncid, ndata_ID, 'units', 'nondimensional');

netcdf.endDef(ncid);
netcdf.close(ncid);