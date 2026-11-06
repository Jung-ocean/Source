function [status]=c_boundary_spitz(S)

%
% C_BOUNDARY_SPITZ:  Creates a ROMS boundary file for one biology tracer
%
% [status]=c_boundary_spitz(S)
%
% Creates a ROMS open boundary conditions NetCDF file holding a single
% Spitz biology model tracer.  The file structure follows the physical
% boundary file written by c_boundary.m (same dimension names, the same
% '<variable>_<edge>' naming convention, the same 'bry_time' unlimited
% record dimension, and single precision data), but only the RHO-point
% grid variables a tracer needs are defined.  Momentum coordinates
% (lon_u_*, lon_v_*, ...) are omitted because a tracer never uses them.
%
% On Input:
%
%    S           Boundary conditions creation parameters (structure array):
%
%                  S.ncname           NetCDF file name
%                  S.spherical        Spherical grid switch
%                  S.Lm               Number of interior RHO-points in X
%                  S.Mm               Number of interior RHO-points in Y
%                  S.N                Number of vertical levels
%                  S.NT               Number of active and passive tracers
%                  S.boundary(4)      Boundary edge switches, in the order
%                                       west, east, south, north
%                  S.Vtransform       Vertical transformation equation
%                  S.bio_name         Biology tracer name
%                  S.bio_long_name    Biology tracer long name
%                  S.bio_units        Biology tracer units
%
% On Output:
%
%    status      Error flag.
%

%--------------------------------------------------------------------------
%  Get creation parameters.
%--------------------------------------------------------------------------

req = {'ncname', 'Lm', 'Mm', 'N', 'boundary',                           ...
       'bio_name', 'bio_long_name', 'bio_units'};
for n=1:length(req)
  if (~isfield(S, req{n})),
    error(['C_BOUNDARY_SPITZ - cannot find parameter: ', req{n},        ...
           ', in structure array S']);
  end
end

ncname = S.ncname;

if (isfield(S,'spherical')),
  spherical = S.spherical;
else
  spherical = 0;
end

if (isfield(S,'Vtransform')),
  Vtransform = S.Vtransform;
else
  Vtransform = 2;
end

if (isfield(S,'NT')),
  NT = S.NT;
else
  NT = 2;
end

Lp = S.Lm+2;
Mp = S.Mm+2;
N  = S.N;

vartype = nc_constant('nc_float');        % single precision, as c_boundary

%--------------------------------------------------------------------------
%  Set dimensions.  The names match the physical boundary file.
%--------------------------------------------------------------------------

Dname.xr   = 'xi_rho';       Dsize.xr   = Lp;
Dname.yr   = 'eta_rho';      Dsize.yr   = Mp;
Dname.Nr   = 's_rho';        Dsize.Nr   = N;
Dname.Nw   = 's_w';          Dsize.Nw   = N+1;
Dname.NT   = 'tracer';       Dsize.NT   = NT;
Dname.time = 'bry_time';     Dsize.time = netcdf.getConstant('UNLIMITED');

%--------------------------------------------------------------------------
%  Set boundary edge strings.
%--------------------------------------------------------------------------

Bname = {'west','east','south','north'};

Blong = {'western boundary condition',                                  ...
         'eastern boundary condition',                                  ...
         'southern boundary condition',                                 ...
         'northern boundary condition'};

if (spherical)
  BcoorX = {'lon_rho_west','lon_rho_east','lon_rho_south','lon_rho_north'};
  BcoorY = {'lat_rho_west','lat_rho_east','lat_rho_south','lat_rho_north'};
else
  BcoorX = {'x_rho_west','x_rho_east','x_rho_south','x_rho_north'};
  BcoorY = {'y_rho_west','y_rho_east','y_rho_south','y_rho_north'};
end

%--------------------------------------------------------------------------
%  Create NetCDF file.
%--------------------------------------------------------------------------

mode = netcdf.getConstant('CLOBBER');
mode = bitor(mode, netcdf.getConstant('64BIT_OFFSET'));

ncid = netcdf.create(ncname, mode);

%--------------------------------------------------------------------------
%  Define dimensions.
%--------------------------------------------------------------------------

did.xr   = netcdf.defDim(ncid, Dname.xr,   Dsize.xr);
did.yr   = netcdf.defDim(ncid, Dname.yr,   Dsize.yr);
did.Nr   = netcdf.defDim(ncid, Dname.Nr,   Dsize.Nr);
did.Nw   = netcdf.defDim(ncid, Dname.Nw,   Dsize.Nw);
did.NT   = netcdf.defDim(ncid, Dname.NT,   Dsize.NT);
did.time = netcdf.defDim(ncid, Dname.time, Dsize.time);

%  Boundary edge dimension: west and east run along eta_rho, south and
%  north run along xi_rho.

did.br = [did.yr did.yr did.xr did.xr];

%--------------------------------------------------------------------------
%  Define grid variables.
%--------------------------------------------------------------------------

Var.name          = 'spherical';
Var.type          = netcdf.getConstant('nc_int');
Var.dimid         = [];
Var.long_name     = 'grid type logical switch';
Var.flag_values   = [0 1];
Var.flag_meanings = ['Cartesian', blanks(1), 'spherical'];
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'Vtransform';
Var.type          = nc_constant('nc_int');
Var.dimid         = [];
Var.long_name     = 'vertical terrain-following transformation equation';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'Vstretching';
Var.type          = nc_constant('nc_int');
Var.dimid         = [];
Var.long_name     = 'vertical terrain-following stretching function';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'theta_s';
Var.type          = nc_constant('nc_double');
Var.dimid         = [];
Var.long_name     = 'S-coordinate surface control parameter';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'theta_b';
Var.type          = nc_constant('nc_double');
Var.dimid         = [];
Var.long_name     = 'S-coordinate bottom control parameter';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'Tcline';
Var.type          = nc_constant('nc_double');
Var.dimid         = [];
Var.long_name     = 'S-coordinate surface/bottom layer width';
Var.units         = 'meter';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name          = 'hc';
Var.type          = nc_constant('nc_double');
Var.dimid         = [];
Var.long_name     = 'S-coordinate parameter, critical depth';
Var.units         = 'meter';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name            = 's_rho';
Var.type            = nc_constant('nc_double');
Var.dimid           = [did.Nr];
Var.long_name       = 'S-coordinate at RHO-points';
Var.valid_min       = -1;
Var.valid_max       = 0;
Var.positive        = 'up';
if (Vtransform == 1),
  Var.standard_name = 'ocean_s_coordinate_g1';
elseif (Vtransform == 2),
  Var.standard_name = 'ocean_s_coordinate_g2';
end
Var.formula_terms   = 's: s_rho C: Cs_r eta: zeta depth: h depth_c: hc';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name            = 's_w';
Var.type            = nc_constant('nc_double');
Var.dimid           = [did.Nw];
Var.long_name       = 'S-coordinate at W-points';
Var.valid_min       = -1;
Var.valid_max       = 0;
Var.positive        = 'up';
if (Vtransform == 1),
  Var.standard_name = 'ocean_s_coordinate_g1';
elseif (Vtransform == 2),
  Var.standard_name = 'ocean_s_coordinate_g2';
end
Var.formula_terms   = 's: s_w C: Cs_w eta: zeta depth: h depth_c: hc';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name            = 'Cs_r';
Var.type            = nc_constant('nc_double');
Var.dimid           = [did.Nr];
Var.long_name       = 'S-coordinate stretching function at RHO-points';
Var.valid_min       = -1;
Var.valid_max       = 0;
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

Var.name            = 'Cs_w';
Var.type            = nc_constant('nc_double');
Var.dimid           = [did.Nw];
Var.long_name       = 'S-coordinate stretching function at W-points';
Var.valid_min       = -1;
Var.valid_max       = 0;
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

%--------------------------------------------------------------------------
%  Define RHO-point coordinates for the processed boundary edges.
%--------------------------------------------------------------------------

for ib=1:4
  if (S.boundary(ib))
    Var.name          = char(BcoorX(ib));
    Var.type          = vartype;
    Var.dimid         = [did.br(ib)];
    if (spherical)
      Var.long_name   = strcat(['longitude of RHO-points, ',            ...
                                char(Blong(ib))]);
      Var.units       = 'degree_east';
      Var.standard_name = 'longitude';
    else
      Var.long_name   = strcat(['X-location of RHO-points, ',           ...
                                char(Blong(ib))]);
      Var.units       = 'meter';
    end
    [~,status]=nc_vdef(ncid,Var);
    if (status ~= 0), return, end
    clear Var

    Var.name          = char(BcoorY(ib));
    Var.type          = vartype;
    Var.dimid         = [did.br(ib)];
    if (spherical)
      Var.long_name   = strcat(['latitute of RHO-points, ',             ...
                                char(Blong(ib))]);
      Var.units       = 'degree_north';
      Var.standard_name = 'latitude';
    else
      Var.long_name   = strcat(['Y-location of RHO-points, ',           ...
                                char(Blong(ib))]);
      Var.units       = 'meter';
    end
    [~,status]=nc_vdef(ncid,Var);
    if (status ~= 0), return, end
    clear Var
  end
end

%--------------------------------------------------------------------------
%  Define boundary conditions time.
%--------------------------------------------------------------------------

Var.name            = 'bry_time';
Var.type            = nc_constant('nc_double');
Var.dimid           = [did.time];
Var.long_name       = 'time since initialization';
Var.units           = 'seconds';
[~,status]=nc_vdef(ncid,Var);
if (status ~= 0), return, end
clear Var

%--------------------------------------------------------------------------
%  Define the biology tracer boundary variables.
%--------------------------------------------------------------------------

for ib=1:4
  if (S.boundary(ib))
    Var.name        = strcat([S.bio_name,'_',char(Bname(ib))]);
    Var.type        = vartype;
    Var.dimid       = [did.time did.Nr did.br(ib)];
    Var.long_name   = strcat([S.bio_long_name, ', ', char(Blong(ib))]);
    Var.units       = S.bio_units;
    Var.time        = 'bry_time';
    Var.coordinates = strcat([char(BcoorX(ib)),' ',                     ...
                              char(BcoorY(ib)),' s_rho bry_time']);
    [~,status]=nc_vdef(ncid,Var);
    if (status ~= 0), return, end
    clear Var
  end
end

%--------------------------------------------------------------------------
%  Create global attributes.
%--------------------------------------------------------------------------

varid = netcdf.getConstant('nc_global');

netcdf.putAtt(ncid, varid, 'type', 'BOUNDARY file');

history = ['Biology boundary file using Matlab script: ',               ...
           'c_boundary_spitz, ', date_stamp];
netcdf.putAtt(ncid, varid, 'history', history);

%--------------------------------------------------------------------------
%  Leave definition mode and close NetCDF file.
%--------------------------------------------------------------------------

netcdf.endDef(ncid);
netcdf.close(ncid);

return
