% Create a netcdf file of boundary condition data for ROMS
%
% It is assumed the data to be written are on a ROMS 3-D grid, but only the
% boundary segments will be used. (OK, so it uses a lot of space but it
% makes it easy to recycle code).
%
% The ROMS 3-D data must be a structure named 'roms'
%   roms.time      = the times of the data
%   roms.base_date = COARDS format string describing base date
%   roms.temp      = temperature observations (such as from Ridgway's SBT
%                     method)
%   roms.salt
%   roms.{u,v,ubar,vbar} on their respective Arakawa-C grid locations
% 
%   add possibly also...
%   roms.temp_err  = normalized error variance of observations 
%   roms.salt_err
%   roms.Evel on the C-grid rho points <<< !!!!!!!!!! <<<<<<<<<<<<<<<<<
%
% Additional data required in the workspace are:
%
%   time_variable = name of the time variable (string)
%   out_file = the name of the netcdf file generated here
%   grd_file (for the record)
%
% Optional data in the workspace
%   titlestr
%   sourcestr = something aobut where the data came from
%   details = something about computations relevant to these data
%
% John Wilkin
% Updated for EAC 15-Aug-2003

disp(' ')
disp(['The output netcdf file (out_file) will be ' out_file])

switch noclobber
  case 1
    nc = netcdf(out_file,'noclobber');
  case 0
    nc = netcdf(out_file,'clobber');
  otherwise
end
if isempty(nc)
  error(['Failed to open ' out_file])
end

% global attributes

try
  nc.type = ncchar(roms.type);
catch
  nc.type = ncchar('ROMS BOUNDARY file');
end

if exist('titlestr')
  nc.title = ncchar(titlestr);
end
if exist('out_file')
  nc.out_file = ncchar(out_file);
end
if exist('grd_file')
  nc.grd_file = ncchar(grd_file);
end
if exist('sourcestr')
  nc.source = ncchar(sourcestr);
end
if exist('details')
  nc.details = ncchar(details);
end
if exist('reference_string')
  nc.reference = ncchar(reference_string); 
end
nc.history = ncchar(['Created by ' which(mfilename) ' - ' datestr(now)]);

% dimensions

eta_rho = size(roms.grd.lon_rho,1);
xi_rho = size(roms.grd.lon_rho,2);
eta_u = size(roms.grd.lon_u,1);
xi_u = size(roms.grd.lon_u,2);
eta_v = size(roms.grd.lon_v,1);
xi_v = size(roms.grd.lon_v,2);

s_rho = length(roms.grd.sc_r);
s_w = length(roms.grd.sc_w);

nc('eta_rho') = eta_rho;
nc('xi_rho') = xi_rho;
nc('eta_u') = eta_u;
nc('xi_u') = xi_u;
nc('eta_v') = eta_v;
nc('xi_v') = xi_v;
nc('s_rho') = s_rho;
nc('s_w') = s_w;
nc('one') = 1;

% The unlimited dimension
time_dimension = 'time';
nc(time_dimension) = 0; % UNLIMITED

if exist('generic_tracer')
  if generic_tracer
    other_time_dimension = 'ones_time'; % for the generic unscaled tracer
    nc(other_time_dimension) = 2; 
  end
end

% coordinates ------------------------------------------------------------

% THE TIME

theVarname = time_variable;
nc{theVarname} = ncfloat(time_dimension);
nc{theVarname}.long_name = ncchar('subsurface temp/salt observations time');
nc{theVarname}.units = ncchar(time_variable_units);
nc{theVarname}.field = ncchar([theVarname ', scalar, series']);
nc{theVarname}.cycle_length = ncfloat(cycle_length);

if exist('generic_tracer')
  if generic_tracer
    theVarname = 'ones_time';
    nc{theVarname} = ncfloat(other_time_dimension);
    nc{theVarname}.long_name = ncchar('generic unit tracer time');
    nc{theVarname}.units = ncchar(time_variable_units);
    nc{theVarname}.field = ncchar([theVarname ', scalar, series']);
  end  
end

% THE VERTICAL COORDINATE VARIABLES

theVarname = 'theta_s';
nc{theVarname} = ncfloat;
nc{theVarname}.long_name = ncchar('S-coordinate surface control parameter');
nc{theVarname}.units = ncchar('nondimensional');

theVarname = 'theta_b';
nc{theVarname} = ncfloat;
nc{theVarname}.long_name = ncchar('S-coordinate bottom control parameter');
nc{theVarname}.units = ncchar('nondimensional');

theVarname = 'Tcline';
nc{theVarname} = ncfloat;
nc{theVarname}.long_name = ncchar('S-coordinate surface/bottom layer width');
nc{theVarname}.units = ncchar('meter');

theVarname = 'hc';
nc{theVarname} = ncfloat;
nc{theVarname}.long_name = ncchar('S-coordinate parameter, critical depth');
nc{theVarname}.units = ncchar('meter');

theVarname = 'sc_r';
nc{theVarname} = ncfloat('s_rho');
nc{theVarname}.long_name = ncchar('S-coordinate at RHO-points');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.valid_min = -1;
nc{theVarname}.valid_max = 0;
nc{theVarname}.field = ncchar('sc_r, scalar');

theVarname = 'sc_w';
nc{theVarname} = ncfloat('s_w');
nc{theVarname}.long_name = ncchar('S-coordinate at W-points');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.valid_min = -1;
nc{theVarname}.valid_max = 0;
nc{theVarname}.field = ncchar('sc_w, scalar');

theVarname = 'Cs_r';
nc{theVarname} = ncfloat('s_rho');
nc{theVarname}.long_name = ncchar('S-coordinate stretching curves at RHO-points');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.valid_min = -1;
nc{theVarname}.valid_max = 0;
nc{theVarname}.field = ncchar('Cs_r, scalar');

theVarname = 'Cs_w';
nc{theVarname} = ncfloat('s_w');
nc{theVarname}.long_name = ncchar('S-coordinate stretching curves at W-points');
nc{theVarname}.units = ncchar('nondimensional');
nc{theVarname}.valid_min = -1;
nc{theVarname}.valid_max = 0;
nc{theVarname}.field = ncchar('Cs_r, scalar');

%% enter the values
%nc{'theta_s'}(:) = roms.grd.theta_s;
%nc{'theta_b'}(:) = roms.grd.theta_b;
%nc{'Tcline'}(:)  = roms.grd.Tcline;
%nc{'hc'}(:)      = roms.grd.hc;
%nc{'sc_r'}(:)    = roms.grd.sc_r;
%nc{'sc_w'}(:)    = roms.grd.sc_w;
%nc{'Cs_r'}(:)    = roms.grd.Cs_r;
%nc{'Cs_w'}(:)    = roms.grd.Cs_w;
% enter the values
nc{'theta_s'}(:) = gn.theta_s;
nc{'theta_b'}(:) = gn.theta_b;
nc{'Tcline'}(:)  = gn.Tcline;
nc{'hc'}(:)      = gn.hc;
nc{'sc_r'}(:)    = gn.sc_r;
nc{'sc_w'}(:)    = gn.sc_w;
nc{'Cs_r'}(:)    = gn.Cs_r;
nc{'Cs_w'}(:)    = gn.Cs_w;

% THE CLIMATOLOGY VARIABLES

% NOTE: These variable names (and the associated time variable names) need
% to correspond the the entires in roms:init_scalars.F

theVarname = 'zeta_east';
nc{theVarname} = ncfloat(time_dimension, 'eta_rho');
nc{theVarname}.long_name = ncchar('free surface east boundary condition');
nc{theVarname}.units = ncchar('meter');
nc{theVarname}.field = ncchar('zeta_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'zeta_west';
nc{theVarname} = ncfloat(time_dimension, 'eta_rho');
nc{theVarname}.long_name = ncchar('free surface west boundary condition');
nc{theVarname}.units = ncchar('meter');
nc{theVarname}.field = ncchar('zeta_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'zeta_north';
nc{theVarname} = ncfloat(time_dimension, 'xi_rho');
nc{theVarname}.long_name = ncchar('free surface north boundary condition');
nc{theVarname}.units = ncchar('meter');
nc{theVarname}.field = ncchar('zeta_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'zeta_south';
nc{theVarname} = ncfloat(time_dimension, 'xi_rho');
nc{theVarname}.long_name = ncchar('free surface south boundary condition');
nc{theVarname}.units = ncchar('meter');
nc{theVarname}.field = ncchar('zeta_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'ubar_east';
nc{theVarname} = ncfloat(time_dimension, 'eta_u');
nc{theVarname}.long_name = ncchar('2D u-momentum east boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('ubar_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'ubar_west';
nc{theVarname} = ncfloat(time_dimension, 'eta_u');
nc{theVarname}.long_name = ncchar('2D u-momentum west boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('ubar_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'ubar_north';
nc{theVarname} = ncfloat(time_dimension, 'xi_u');
nc{theVarname}.long_name = ncchar('2D u-momentum north boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('ubar_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'ubar_south';
nc{theVarname} = ncfloat(time_dimension, 'xi_u');
nc{theVarname}.long_name = ncchar('2D u-momentum south boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('ubar_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'vbar_east';
nc{theVarname} = ncfloat(time_dimension, 'eta_v');
nc{theVarname}.long_name = ncchar('2D v-momentum east boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('vbar_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'vbar_west';
nc{theVarname} = ncfloat(time_dimension, 'eta_v');
nc{theVarname}.long_name = ncchar('2D v-momentum west boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('vbar_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'vbar_north';
nc{theVarname} = ncfloat(time_dimension, 'xi_v');
nc{theVarname}.long_name = ncchar('2D v-momentum north boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('vbar_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'vbar_south';
nc{theVarname} = ncfloat(time_dimension, 'xi_v');
nc{theVarname}.long_name = ncchar('2D v-momentum south boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('vbar_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'u_east';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_u');
nc{theVarname}.long_name = ncchar('3D u-momentum east boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('u_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'u_west';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_u');
nc{theVarname}.long_name = ncchar('3D u-momentum west boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('u_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'u_north';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_u');
nc{theVarname}.long_name = ncchar('3D u-momentum north boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('u_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'u_south';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_u');
nc{theVarname}.long_name = ncchar('3D u-momentum south boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('u_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'v_east';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_v');
nc{theVarname}.long_name = ncchar('3D v-momentum east boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('v_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'v_west';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_v');
nc{theVarname}.long_name = ncchar('3D v-momentum west boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('v_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'v_north';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_v');
nc{theVarname}.long_name = ncchar('3D v-momentum north boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('v_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'v_south';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_v');
nc{theVarname}.long_name = ncchar('3D v-momentum south boundary condition');
nc{theVarname}.units = ncchar('meter second-1');
nc{theVarname}.field = ncchar('v_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'temp_east';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_rho');
nc{theVarname}.long_name = ncchar('potential temperature east boundary condition');
nc{theVarname}.units = ncchar('Celcius');
nc{theVarname}.field = ncchar('temp_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'temp_west';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_rho');
nc{theVarname}.long_name = ncchar('potential temperature west boundary condition');
nc{theVarname}.units = ncchar('Celcius');
nc{theVarname}.field = ncchar('temp_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'temp_north';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_rho');
nc{theVarname}.long_name = ncchar('potential temperature north boundary condition');
nc{theVarname}.units = ncchar('Celcius');
nc{theVarname}.field = ncchar('temp_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'temp_south';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_rho');
nc{theVarname}.long_name = ncchar('potential temperature south boundary condition');
nc{theVarname}.units = ncchar('Celcius');
nc{theVarname}.field = ncchar('temp_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'salt_east';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_rho');
nc{theVarname}.long_name = ncchar('salinity east boundary condition');
nc{theVarname}.units = ncchar('PSU');
nc{theVarname}.field = ncchar('salt_east, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'salt_west';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'eta_rho');
nc{theVarname}.long_name = ncchar('salinity west boundary condition');
nc{theVarname}.units = ncchar('PSU');
nc{theVarname}.field = ncchar('salt_west, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'salt_north';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_rho');
nc{theVarname}.long_name = ncchar('salinity north boundary condition');
nc{theVarname}.units = ncchar('PSU');
nc{theVarname}.field = ncchar('salt_north, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

theVarname = 'salt_south';
nc{theVarname} = ncfloat(time_dimension, 's_rho', 'xi_rho');
nc{theVarname}.long_name = ncchar('salinity south boundary condition');
nc{theVarname}.units = ncchar('PSU');
nc{theVarname}.field = ncchar('salt_south, scalar, series');
nc{theVarname}.time = ncchar(time_variable);

% specify additional tracers here
if ~exist('donuts')
  donuts = 0;
end

if donuts

  tnum = 1;

  tracer(tnum).name = 'NO3';
  tracer(tnum).long_name = 'nitrate concentration';
  tracer(tnum).units = 'millimole nitrogen meter-3';
  tracer(tnum).time = time_variable;
  tracer(tnum).time_dimension = 'time';
  tracer(tnum).fillvalue = 0.;

  if exist('generic_tracer')
    if generic_tracer
      tnum = tnum+1;
      tracer(tnum).name = 'ONES';
      tracer(tnum).long_name = 'generic unit tracer to be scaled by Fscale';
      tracer(tnum).units = 'dimensionless';
      tracer(tnum).time = 'ones_time';
      tracer(tnum).time_dimension = 'ones_time';
      tracer(tnum).fillvalue = 0.;
    end
  end
  
  for nuts=1:size(tracer,2)
      
    for bndys = { 'east','west','north','south'}
      bndy = char(bndys);
      theVarname = [tracer(nuts).name '_' bndy];
      switch bndy
	case {'east','west'}
	  nc{theVarname} = ncfloat(tracer(nuts).time_dimension, ...
	      's_rho', 'eta_rho');
	case {'north','south'}
	  nc{theVarname} = ncfloat(tracer(nuts).time_dimension, ...
	      's_rho', 'xi_rho');
      end      
      nc{theVarname}.long_name = ...
	  ncchar([tracer(nuts).long_name ' ' bndy ' boundary condition']);
      nc{theVarname}.units = ncchar(tracer(nuts).units);
      nc{theVarname}.field = ncchar([theVarname ', scalar, series']);
      nc{theVarname}.FillValue_ = tracer(nuts).fillvalue;
      nc{theVarname}.time = ncchar(tracer(nuts).time);
    end
      
  end % nuts
    
end % additional tracers

% force write-to-disk of the configuration and coordinates
% will need to re-open the file to write the data

close(nc)
