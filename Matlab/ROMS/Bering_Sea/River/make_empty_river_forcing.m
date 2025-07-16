function make_empty_river_forcing(filename, grid, river, Np)

ncid = netcdf.create(filename,'CLOBBER');
river_dimID = netcdf.defDim(ncid,'river',Np);
s_rho_dimID = netcdf.defDim(ncid,'s_rho',grid.N);
river_time_dimID = netcdf.defDim(ncid,'river_time', ...
    netcdf.getConstant('NC_UNLIMITED'));

varid = netcdf.getConstant('GLOBAL');
netcdf.putAtt(ncid,varid,'type','ROMS FORCING file')
netcdf.putAtt(ncid,varid,'title','Bering Sea River Forcing')
netcdf.putAtt(ncid,varid,'grd_file',grid.Gname)
netcdf.putAtt(ncid,varid,'rivers',['(1) ', river{1}, ' (2) ', river{2}, ' (3) ', river{3}, ' (4) ', river{4}, ' (5) ', river{5}, ' (6) ', river{6}, ' and others'])
netcdf.putAtt(ncid,varid,'creation_date',datestr(now))
netcdf.putAtt(ncid,varid,'creator','Jihun Jung (jihun.jung@oregonstate.edu)')

varid = netcdf.defVar(ncid,'river','NC_DOUBLE', river_dimID);
netcdf.putAtt(ncid,varid,'long_name','river runoff identification number');

varid = netcdf.defVar(ncid,'river_Eposition','NC_DOUBLE', river_dimID);
netcdf.putAtt(ncid,varid,'long_name','river ETA-position at RHO-points');
netcdf.putAtt(ncid,varid,'valid_min',1.);
netcdf.putAtt(ncid,varid,'valid_max',size(grid.mask_r,2));

varid = netcdf.defVar(ncid,'river_Vshape','NC_DOUBLE', [river_dimID s_rho_dimID]);
netcdf.putAtt(ncid,varid,'long_name','river runoff mass transport vertical profile');

varid = netcdf.defVar(ncid,'river_Xposition','NC_DOUBLE', river_dimID);
netcdf.putAtt(ncid,varid,'long_name','river XI-position at RHO-points');
netcdf.putAtt(ncid,varid,'valid_min',1.);
netcdf.putAtt(ncid,varid,'valid_max',size(grid.mask_r,1));

varid = netcdf.defVar(ncid,'river_direction','NC_DOUBLE', river_dimID);
netcdf.putAtt(ncid,varid,'long_name','river runoff direction');

varid = netcdf.defVar(ncid,'river_salt','NC_DOUBLE', [river_dimID s_rho_dimID river_time_dimID]);
netcdf.putAtt(ncid,varid,'long_name','river runoff salinity');
netcdf.putAtt(ncid,varid,'time','river_time');

varid = netcdf.defVar(ncid,'river_temp','NC_DOUBLE', [river_dimID s_rho_dimID river_time_dimID]);
netcdf.putAtt(ncid,varid,'long_name','river runoff potential temperature');
netcdf.putAtt(ncid,varid,'units','Celsius');
netcdf.putAtt(ncid,varid,'time','river_time');

varid = netcdf.defVar(ncid,'river_time','NC_DOUBLE', river_time_dimID);
netcdf.putAtt(ncid,varid,'long_name','river runoff time');
netcdf.putAtt(ncid,varid,'units','days since 1968-05-23 00:00:00');
netcdf.putAtt(ncid,varid,'add_offset',0.);

varid = netcdf.defVar(ncid,'river_transport','NC_DOUBLE', [river_dimID river_time_dimID]);
netcdf.putAtt(ncid,varid,'long_name','river runoff vertically integrated mass transport');
netcdf.putAtt(ncid,varid,'units','meter3 second-1');
netcdf.putAtt(ncid,varid,'time','river_time');

netcdf.close(ncid)

end