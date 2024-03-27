function make_empty_HYCOM_for_SCHISM(filename, lat,lon,depth)

% Define dimensions
time_size = 0;
ylat_size = lat;
xlon_size = lon;
depth_size = depth;

% Create NetCDF file
ncid = netcdf.create(filename, 'NC_WRITE');

% Define dimensions
dimid_time = netcdf.defDim(ncid, 'time', time_size);
dimid_ylat = netcdf.defDim(ncid, 'ylat', ylat_size);
dimid_xlon = netcdf.defDim(ncid, 'xlon', xlon_size);
dimid_depth = netcdf.defDim(ncid, 'depth', depth_size);

% Define coordinate variables
varid_ylat = netcdf.defVar(ncid, 'ylat', 'double', dimid_ylat);
netcdf.putAtt(ncid, varid_ylat, '_FillValue', NaN);
netcdf.putAtt(ncid, varid_ylat, 'long_name', 'Latitude');
netcdf.putAtt(ncid, varid_ylat, 'standard_name', 'latitude');
netcdf.putAtt(ncid, varid_ylat, 'units', 'degrees_north');
netcdf.putAtt(ncid, varid_ylat, 'axis', 'Y');
netcdf.putAtt(ncid, varid_ylat, 'NAVO_code', 1);

varid_xlon = netcdf.defVar(ncid, 'xlon', 'double', dimid_xlon);
netcdf.putAtt(ncid, varid_xlon, '_FillValue', NaN);
netcdf.putAtt(ncid, varid_xlon, 'long_name', 'Longitude');
netcdf.putAtt(ncid, varid_xlon, 'standard_name', 'longitude');
netcdf.putAtt(ncid, varid_xlon, 'units', 'degrees_east');
netcdf.putAtt(ncid, varid_xlon, 'modulo', '360 degrees');
netcdf.putAtt(ncid, varid_xlon, 'axis', 'X');
netcdf.putAtt(ncid, varid_xlon, 'NAVO_code', 2);

varid_time = netcdf.defVar(ncid, 'time', 'double', dimid_time);
netcdf.putAtt(ncid, varid_time, '_FillValue', NaN);
netcdf.putAtt(ncid, varid_time, 'long_name', 'Valid Time');
netcdf.putAtt(ncid, varid_time, 'time_origin', '2000-01-01 00:00:00');
netcdf.putAtt(ncid, varid_time, 'axis', 'T');
netcdf.putAtt(ncid, varid_time, 'NAVO_code', 13);
netcdf.putAtt(ncid, varid_time, 'units', 'hours since 2000-01-01');
netcdf.putAtt(ncid, varid_time, 'calendar', 'gregorian');

varid_depth = netcdf.defVar(ncid, 'depth', 'double', dimid_depth);
netcdf.putAtt(ncid, varid_depth, '_FillValue', NaN);
netcdf.putAtt(ncid, varid_depth, 'long_name', 'Depth');
netcdf.putAtt(ncid, varid_depth, 'standard_name', 'depth');
netcdf.putAtt(ncid, varid_depth, 'units', 'm');
netcdf.putAtt(ncid, varid_depth, 'positive', 'down');
netcdf.putAtt(ncid, varid_depth, 'axis', 'Z');
netcdf.putAtt(ncid, varid_depth, 'NAVO_code', 5);

% Define variables
varid_surf_el = netcdf.defVar(ncid, 'surf_el', 'short', [dimid_xlon dimid_ylat dimid_time]);
netcdf.putAtt(ncid, varid_surf_el, '_FillValue', int16(-30000));
netcdf.putAtt(ncid, varid_surf_el, '_CoordinateAxes', 'time lat lon ');
netcdf.putAtt(ncid, varid_surf_el, 'long_name', 'Water Surface Elevation');
netcdf.putAtt(ncid, varid_surf_el, 'standard_name', 'sea_surface_elevation');
netcdf.putAtt(ncid, varid_surf_el, 'units', 'm');
netcdf.putAtt(ncid, varid_surf_el, 'NAVO_code', 32);
netcdf.putAtt(ncid, varid_surf_el, 'add_offset', single(0));
netcdf.putAtt(ncid, varid_surf_el, 'scale_factor', single(0.001));
netcdf.putAtt(ncid, varid_surf_el, 'missing_value', int16(-30000));

varid_salinity = netcdf.defVar(ncid, 'salinity', 'short', [dimid_xlon dimid_ylat dimid_depth dimid_time]);
netcdf.putAtt(ncid, varid_salinity, '_FillValue', int16(-30000));
netcdf.putAtt(ncid, varid_salinity, '_CoordinateAxes', 'time depth lat lon ');
netcdf.putAtt(ncid, varid_salinity, 'long_name', 'Salinity');
netcdf.putAtt(ncid, varid_salinity, 'standard_name', 'sea_water_salinity');
netcdf.putAtt(ncid, varid_salinity, 'units', 'psu');
netcdf.putAtt(ncid, varid_salinity, 'NAVO_code', 16);
netcdf.putAtt(ncid, varid_salinity, 'add_offset', single(20));
netcdf.putAtt(ncid, varid_salinity, 'scale_factor', single(0.001));
netcdf.putAtt(ncid, varid_salinity, 'missing_value', int16(-30000));

varid_water_u = netcdf.defVar(ncid, 'water_u', 'short', [dimid_xlon dimid_ylat dimid_depth dimid_time]);
netcdf.putAtt(ncid, varid_water_u, '_FillValue', int16(-30000));
netcdf.putAtt(ncid, varid_water_u, '_CoordinateAxes', 'time depth lat lon ');
netcdf.putAtt(ncid, varid_water_u, 'long_name', 'Eastward Water Velocity');
netcdf.putAtt(ncid, varid_water_u, 'standard_name', 'eastward_sea_water_velocity');
netcdf.putAtt(ncid, varid_water_u, 'units', 'm/s');
netcdf.putAtt(ncid, varid_water_u, 'NAVO_code', 17);
netcdf.putAtt(ncid, varid_water_u, 'add_offset', single(0));
netcdf.putAtt(ncid, varid_water_u, 'scale_factor', single(0.001));
netcdf.putAtt(ncid, varid_water_u, 'missing_value', int16(-30000));

varid_water_u = netcdf.defVar(ncid, 'water_v', 'short', [dimid_xlon dimid_ylat dimid_depth dimid_time]);
netcdf.putAtt(ncid, varid_water_u, '_FillValue', int16(-30000));
netcdf.putAtt(ncid, varid_water_u, '_CoordinateAxes', 'time depth lat lon ');
netcdf.putAtt(ncid, varid_water_u, 'long_name', 'Northward Water Velocity');
netcdf.putAtt(ncid, varid_water_u, 'standard_name', 'northward_sea_water_velocity');
netcdf.putAtt(ncid, varid_water_u, 'units', 'm/s');
netcdf.putAtt(ncid, varid_water_u, 'NAVO_code', 18);
netcdf.putAtt(ncid, varid_water_u, 'add_offset', single(0));
netcdf.putAtt(ncid, varid_water_u, 'scale_factor', single(0.001));
netcdf.putAtt(ncid, varid_water_u, 'missing_value', int16(-30000));

varid_temperature = netcdf.defVar(ncid, 'temperature', 'short', [dimid_xlon dimid_ylat dimid_depth dimid_time]);
netcdf.putAtt(ncid, varid_temperature, '_FillValue', int16(-30000));
netcdf.putAtt(ncid, varid_temperature, 'long_name', 'Sea water potential temperature');
netcdf.putAtt(ncid, varid_temperature, 'standard_name', 'sea_water_potential_temperature');
netcdf.putAtt(ncid, varid_temperature, 'units', 'degC');
netcdf.putAtt(ncid, varid_temperature, 'add_offset', single(20));
netcdf.putAtt(ncid, varid_temperature, 'scale_factor', single(0.001));
netcdf.putAtt(ncid, varid_temperature, 'missing_value', int16(-30000));

% Add global attributes
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'classification_level', 'UNCLASSIFIED');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'distribution_statement', 'Approved for public release. Distribution unlimited.');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'downgrade_date', 'not applicable');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'classification_authority', 'not applicable');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', 'Fleet Numerical Meteorology and Oceanography Center');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'source', 'HYCOM archive file');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', 'archv2ncdf2d');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'comment', 'p-grid');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'field_type', 'instantaneous');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'Conventions', 'CF-1.6 NAVO_netcdf_v1.1');

% Close NetCDF file
netcdf.close(ncid);

end
