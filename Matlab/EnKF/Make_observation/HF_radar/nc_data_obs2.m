function nc_data_obs2(file2, len)
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

nc = netcdf(file2, 'clobber');

disp(['xt_i is ',num2str(len)])

nc('time') = 1;
nc('xt_i') = len;

nc.type = ' Hydrographic Data Assimilation - file ';
nc.title = ' Jeju HFradar file ';
nc.source = ' Jeju HFradar file ';
nc.author = 'Created by J.Jung';
nc.date = date;

 nc{'ixt'} = ncfloat('xt_i');
 nc{'ixt'}.long_name = ncchar('Number of the data');
 nc{'ixt'}.units = ncchar('degree');
 
 nc{'time'} = ncdouble('time');
 nc{'time'}.units = ncchar(datestr(datenum(2014,05,01,0,0,0) + str2num(file2(end-6:end-3)),0));
 
 nc{'rlon'} = ncdouble('time', 'xt_i');
 nc{'rlon'}.units = ncchar('degree_E');
 
 nc{'rlat'} = ncdouble('time', 'xt_i');
 nc{'rlat'}.units = ncchar('degree_N');
 
 nc{'rdepth'} = ncdouble('time', 'xt_i');
 nc{'rdepth'}.units = ncchar('m');

 nc{'obsdata'} = ncdouble('time', 'xt_i');
 nc{'obsdata'}.units = ncchar('deg C or psu or m');
 
 nc{'obserr'} = ncdouble('time', 'xt_i');
 nc{'obserr'}.units = ncchar('ssh: 0.05, tem: 0.8~0.1');
 
 nc{'dindex'} = ncdouble('time', 'xt_i');
 nc{'dindex'}.units = ncchar('1: zeta, 2: temp, 3: salt, ...');
 
 nc{'ndata'} = ncdouble('time');
 nc{'ndata'}.units = ncchar('nondimension');
 
close(nc)

end
