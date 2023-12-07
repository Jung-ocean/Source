%-----------------------------------------------------------
%  Create empty river data NetCDF file
%
%   Called from latte_rivers.m
%-----------------------------------------------------------

disp('  ')
disp(['The RIVER netcdf file will be ' Fname])
disp('  ')

    nc = netcdf(Fname,'clobber');

if isempty(nc)
  error(['Failed to open ' Fname])
end

  nc.type = ncchar('ROMS River Forcing file ');
  nc.out_file = ncchar(Fname);
  nc.grd_file = ncchar(grd_file);
  nc.source   = ncchar(Rname);
  nc.details  = ncchar(detailstr);
  nc.history = ncchar(['Created by ' which(mfilename) ' - ' datestr(now)]);

% dimensions

eta_rho = size(grd.lon_rho,1);
xi_rho = size(grd.lon_rho,2);
eta_u = size(grd.lon_u,1);
xi_u = size(grd.lon_u,2);
eta_v = size(grd.lon_v,1);
xi_v = size(grd.lon_v,2);
r_time = length(River.time);
r_time_units = River.time_units;
s_rho = N;
river = r;

nc('xi_rho') = xi_rho;
nc('xi_u') = xi_u;
nc('xi_v') = xi_v;
nc('eta_rho') = eta_rho;
nc('eta_u') = eta_u;
nc('eta_v') = eta_v;
nc('s_rho') = s_rho;
nc('river') = river;
time_dimension = 'time';
nc(time_dimension) = r_time; % UNLIMITED

% the variables

theVarname = 'river';
nc{theVarname} = ncfloat('river');
nc{theVarname}.long_name = ncchar('river identification number');
nc{theVarname}.units = ncchar('non-dimensional');
nc{theVarname}.field = ncchar('river, scalar');

theVarname = 'river_name';
nc{theVarname} = ncfloat('river_name');
nc{theVarname}.long_name = ncchar('river name');
%nc{theVarname}.field = ncchar('river_name, scalar');

theVarname = 'river_Xposition';
nc{theVarname} = ncfloat('river');
nc{theVarname}.long_name = ncchar('river XI-position at RHO points');
nc{theVarname}.units = ncchar('non-dimensional');
nc{theVarname}.valid_min = 1;
nc{theVarname}.valid_max = xi_u;
nc{theVarname}.field = ncchar('river_Xposition, scalar');

theVarname = 'river_Eposition';
nc{theVarname} = ncfloat('river');
nc{theVarname}.long_name = ncchar('river ETA-position at RHO points');
nc{theVarname}.units = ncchar('non-dimensional');
nc{theVarname}.valid_min = 1;
nc{theVarname}.valid_max = eta_v;
nc{theVarname}.field = ncchar('river_Eposition, scalar');

theVarname = 'river_direction';
nc{theVarname} = ncfloat('river');
nc{theVarname}.long_name = ncchar('river runoff direction');
nc{theVarname}.units = ncchar('non-dimensional');
nc{theVarname}.field = ncchar('river_direction, scalar');

theVarname = 'river_flag';
nc{theVarname} = ncfloat('river');
nc{theVarname}.long_name = ncchar('river runoff tracer flag');
nc{theVarname}.option_0 = ncchar('all tracers are off');
nc{theVarname}.option_1 = ncchar('only temperature is on');
nc{theVarname}.option_2 = ncchar('only salinity is on');
nc{theVarname}.option_3 = ncchar('both temperature and salinity are on');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.field = ncchar('river_flag, scalar');

theVarname = 'river_Vshape';
nc{theVarname} = ncfloat('s_rho','river');
nc{theVarname}.long_name = ncchar('river runoff mass tranport vertical profile');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.field = ncchar('river_Vshape, scalar');

theVarname = 'river_time';
nc{theVarname} = ncfloat('time');
nc{theVarname}.long_name = ncchar('river day of year');
nc{theVarname}.units = ncchar(r_time_units);
nc{theVarname}.cycle_length = 365.25 ;
nc{theVarname}.field = ncchar('river_time, scalar, series');

theVarname = 'river_transport';
nc{theVarname} = ncfloat('time','river');
nc{theVarname}.long_name = ncchar('river runoff volume transport');
nc{theVarname}.units = ncchar('meter^3 / sec');
nc{theVarname}.field = ncchar('river_transport, scalar, series');
nc{theVarname}.time = ncchar('river_time');

theVarname = 'river_temp';
nc{theVarname} = ncfloat('time','s_rho','river');
nc{theVarname}.long_name = ncchar('river runoff potential temperature');
nc{theVarname}.units = ncchar('Celsius');
nc{theVarname}.field = ncchar('river_temp, scalar, series');
nc{theVarname}.time = ncchar('river_time');

theVarname = 'river_salt';
nc{theVarname} = ncfloat('time','s_rho','river');
nc{theVarname}.long_name = ncchar('river runoff salinity');
nc{theVarname}.units = ncchar('PSU');
nc{theVarname}.field = ncchar('river_salt, scalar, series');
nc{theVarname}.time = ncchar('river_time');

result = close(nc);  

