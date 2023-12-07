filename = 'roms_bndy_nwp_1_10_2018_test06_dye.nc';

vari_index_all = 52:63;

for vi = 1:length(vari_index_all)
vari_index = vari_index_all(vi);
    
% Open netCDF file.
ncid = netcdf.open(filename,'NC_WRITE');

% Put file in define mode.
netcdf.reDef(ncid)

% Get name of first variable
[varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,vari_index);

% Rename the variable, using a capital letter to start the name.
netcdf.renameVar(ncid,vari_index,num2str(vari_index))

[varname, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,vari_index);
varname

netcdf.close(ncid)

end
