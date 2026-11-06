function [status]=c_biology_spitz(S)

%
% C_BIOLOGY_SPITZ:  Defines Spitz biology model variables to a ROMS
%                   NetCDF file
%
% [status]=c_biology_spitz(S)
%
% This function defines the biology model tracer variables (NO3, NH4,
% DON, DetN, Bacteria, Phytoplankton, Microzooplankton, Chlorophyll,
% DetC, DOC, Mesozooplankton, Silica, Diatoms, LDetN, LDetC, LDetS,
% ChlD) to an existing initial conditions or climatology ROMS NetCDF
% file. This is adapted from c_biology.m for the biology model used by
% the NOPP_Carbon Oregon_1km application.
%
% On Input:
%
%    S           Initial conditions creation parameters (structure array):
%
%                  S.ncname           NetCDF file name
%                  S.spherical        Spherical grid switch
%
% On Output:
%
%    status      Error flag.
%

%--------------------------------------------------------------------------
%  Check required fields in structure S.
%--------------------------------------------------------------------------

if (isfield(S,'ncname')),
  ncname=S.ncname;
else
  error(['C_BIOLOGY_SPITZ - cannot find NetCDF file name field: ncname, ', ...
         'in structure array S']);
end

if (isfield(S,'spherical')),
  spherical=S.spherical;
else
  spherical=0;
end

%  Set variable type.

vartype=nc_constant('nc_double');

%  Inquire NetCDF file dimensions and their IDs.

D=nc_dinfo(ncname);

for n=1:length(D),
  name=char(D(n).Name);
  switch name
    case 'xi_rho',
      did.xr=D(n).dimid;
    case 'eta_rho',
      did.yr=D(n).dimid;
    case 's_rho',
      did.Nr=D(n).dimid;
    case 'ocean_time',
      did.time=D(n).dimid;
  end
end

%  Horizontal/time coordinates.

Vname.time='ocean_time';

if (spherical),
  Vname.coord='lon_rho lat_rho s_rho ocean_time';
else
  Vname.coord='x_rho y_rho s_rho ocean_time';
end

%--------------------------------------------------------------------------
%  Set biology tracer variables: name, long_name, units.
%--------------------------------------------------------------------------

bio = spitz_bio_vars();

%  Skip any tracer already defined in the file, so this function can be
%  run against a file that already carries some of them.

status=0;

V=nc_vnames(ncname);
ExistingNames = {V.Variables.Name};

define = true([1 length(bio)]);
for n=1:length(bio),
  if (any(strcmp(ExistingNames, bio(n).name))),
    define(n) = false;
    disp(['C_BIOLOGY_SPITZ - variable already defined, skipping: ',     ...
          bio(n).name]);
  end
end

if (~any(define)),
  disp('C_BIOLOGY_SPITZ - all biology variables already defined.');
  return
end

%--------------------------------------------------------------------------
%  Open existing initial conditions or climatology file and put in
%  definition mode.
%--------------------------------------------------------------------------

ncid = netcdf.open(ncname, 'nc_write');
netcdf.reDef(ncid);

%--------------------------------------------------------------------------
%  Define biology tracer variables.
%--------------------------------------------------------------------------

for n=1:length(bio),
  if (~define(n)), continue, end
  Var.name        = bio(n).name;
  Var.type        = vartype;
  Var.dimid       = [did.time did.Nr did.yr did.xr];
  Var.long_name   = bio(n).long_name;
  Var.units       = bio(n).units;
  Var.time        = Vname.time;
  Var.coordinates = Vname.coord;
  [~,status]=nc_vdef(ncid,Var);
  if (status ~= 0),
    netcdf.close(ncid);
    return
  end
  clear Var
end

%--------------------------------------------------------------------------
%  Leave definition mode and close NetCDF file.
%--------------------------------------------------------------------------

netcdf.endDef(ncid);
netcdf.close(ncid);

return
