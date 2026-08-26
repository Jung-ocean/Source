function a=read_whole_field(file,field_list);

% usage: 
% a=read_whole_field(file,field_list);


K=length(field_list);

%ncid=mexnc('open',file,'nowrite');
% for k=1:K
%  field=field_list{k};
%  [varid, status] = mexnc('inq_varid',ncid,field);
%  eval(['[a.' field ',status] = mexnc ( ''get_var_double'', ncid, varid);']); 
% end
%status=mexnc('close',ncid);

ncid = netcdf.open(file,'NC_NOWRITE');
 for k=1:K
  field=field_list{k};
  varid = netcdf.inqVarID(ncid,field);
  eval(['a.' field ' = netcdf.getVar(ncid,varid);']); 
 end
netcdf.close(ncid);

