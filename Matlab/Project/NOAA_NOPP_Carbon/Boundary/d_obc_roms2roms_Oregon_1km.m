%
%  D_OBC_ROMS2ROMS:  Driver script to create a ROMS boundary conditions
%
%  This a user modifiable script that can be used to prepare ROMS open
%  boundary conditions NetCDF file from another ROMS application. It
%  sets-up all the necessary parameters and variables. USERS can use
%  this as a prototype for their application.
%

% svn $Id$
%=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                            Hernan G. Arango      %
%=========================================================================%
clear; clc
%==========================================================================
% This script creates boundary conditions from ROMS NWA dataset.
%==========================================================================
roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

yyyy = 2024;
ystr = num2str(yyyy);

source = 'LiveOcean';
R2R_source_grid = grd('LiveOcean');
datatype = 'daily';

domain = 'Oregon_1km';
g = grd(domain);
refdate = datenum(2024,1,1);
GRDname = g.grd_file;
BRYname = 'boundary_Oregon_1km.nc';

for di = 1:366

filenum = di;
fstr = num2str(filenum, '%04i');

% Set file names (Input data can be in an OpenDAP server).
NWAdata = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_', fstr, '.nc'];
NWAgrid = R2R_source_grid.grd_file;

StrDay = datenum(yyyy,1,1,12,0,0)+di-1;        % starting day to process
EndDay = datenum(yyyy,12,31,12,0,0);        % ending   day to process

if di == 1
    CREATE = true;                          % logical switch to create NetCDF
else
    CREATE = false;                          % logical switch to create NetCDF
end
WRITE  = true;                          % logical switch to write out data
report = false;                         % report vertical grid information

%  Set logical switch to compute time dependent vertical thichnesses (Hz)
%  when computing vertically integrated 2D momentum (ubar,vbar).

TimeDependent = true;

%  Initialize unlimited dimension record counter. Notice that if we want
%  to restart the computations, we can set CREATE = false and get the
% record of the last boundary conditions processed for appending.

if (CREATE)
  BryRec = 0;
else
  BryRec = length(nc_read(BRYname,'bry_time'));
end

%--------------------------------------------------------------------------
%  Set application parameters in structure array, S.
%--------------------------------------------------------------------------

[Lr,Mr] = size(nc_read(GRDname,'h'));

Lu = Lr-1;
Lv = Lr;
Mu = Mr;
Mv = Mr-1;

S.ncname      = BRYname;    % output NetCDF file

S.spherical   = 1;          % spherical grid

S.Lm          = Lr-2;       % number of interior RHO-points, X-direction
S.Mm          = Mr-2;       % number of interior RHO-points, Y-direction
S.N           = g.N;         % number of vertical levels at RHO-points
S.NT          = 2;          % total number of tracers

S.Vtransform  = g.Vtransform;          % vertical transfomation equation
S.Vstretching = g.Vstretching;          % vertical stretching function

S.theta_s     = g.theta_s;        % S-coordinate surface control parameter
S.theta_b     = g.theta_b;        % S-coordinate bottom control parameter
S.Tcline      = g.Tcline;      % S-coordinate surface/bottom stretching width
S.hc          = S.Tcline;   % S-coordinate stretching width

%  Set switches for boundary segments to process.

OBC.west  = true;          % process western  boundary segment
OBC.east  = false;         % process eastern  boundary segment
OBC.south = true;          % process southern boundary segment
OBC.north = true;          % process northern boundary segment

S.boundary(1) = OBC.west;
S.boundary(2) = OBC.east;
S.boundary(3) = OBC.south;
S.boundary(4) = OBC.north;

%--------------------------------------------------------------------------
%  Set variables to process.
%--------------------------------------------------------------------------

%  Grid variables.

VarGrd = {'spherical',                                                ...
          'Vtransform', 'Vstretching',                                ...
          'theta_s', 'theta_b', 'Tcline', 'hc',                       ...
          's_rho', 'Cs_r', 's_w', 'Cs_w'};

if (S.spherical),
  if (OBC.west),
    VarGrd = [VarGrd, 'lon_rho_west',  'lat_rho_west',                ...
                      'lon_u_west',    'lat_u_west',                  ...
                      'lon_v_west',    'lat_v_west'];
  end
  if (OBC.east),
    VarGrd = [VarGrd, 'lon_rho_east',  'lat_rho_east',                ...
                      'lon_u_east',    'lat_u_east',                  ...
                      'lon_v_east',    'lat_v_east'];
  end
  if (OBC.south),
    VarGrd = [VarGrd, 'lon_rho_south', 'lat_rho_south',               ...
                      'lon_u_south',   'lat_u_south',                 ...
                      'lon_v_south',   'lat_v_south'];
  end
  if (OBC.north),
    VarGrd = [VarGrd, 'lon_rho_north', 'lat_rho_north',               ...
                      'lon_u_north',   'lat_u_north',                 ...
                      'lon_v_north',   'lat_v_north'];
  end
else
  if (OBC.west),
    VarGrd = [VarGrd, 'x_rho_west',  'y_rho_west',                    ...
                      'x_u_west',    'y_u_west',                      ...
                      'x_v_west',    'y_v_west'];
  end
  if (OBC.east),
    VarGrd = [VarGrd, 'x_rho_east',  'y_rho_east',                    ...
                      'x_u_east',    'y_u_east',                      ...
                      'x_v_east',    'y_v_east'];
  end
  if (OBC.south),
    VarGrd = [VarGrd, 'x_rho_south', 'y_rho_south',                   ...
                      'x_u_south',   'y_u_south',                     ...
                      'x_v_south',   'y_v_south'];
  end
  if (OBC.north),
    VarGrd = [VarGrd, 'x_rho_north', 'y_rho_north',                   ...
                      'x_u_north',   'y_u_north',                     ...
                      'x_v_north',   'y_v_north'];
  end
end

%  ROMS state variables to process.  In 3D applications, the 2D momentum
%  components (ubar,vbar) are compouted by vertically integrating
%  3D momentum component. Therefore, interpolation of (ubar,vbar) is
%  not carried out for efficiency.

VarBry  = {'zeta', 'u', 'v', 'temp', 'salt'};
VarList = [VarBry, 'ubar', 'vbar'];

%  Set intepolation parameters.

method = 'linear';             % linear interpolation
offset = 10;                   % number of extra points for sampling
RemoveNaN = true;              % remove NaN with nearest-neighbor
Rvector = false;               % interpolate vectors to RHO-points

%--------------------------------------------------------------------------
%  Get parent and target grids structures. The depths are for an
%  unperturbed state (zeta = 0).
%--------------------------------------------------------------------------

%  Get Parent grid structure, P.

% P = get_roms_grid(NWAgrid, NWAdata);
P = R2R_source_grid;

%  Set surface-depths to zero to bound surface interpolation. This is
%  specific for this application.

N = P.N;

P.z_r(:,:,N) = 0;
P.z_u(:,:,N) = 0;
P.z_v(:,:,N) = 0;

%  Get Target grid structure, T.

T = get_roms_grid(GRDname, S);

T.s_rho = g.s_rho;
T.Cs_r = g.Cs_r;
T.s_w = g.s_w;
T.Cs_w = g.Cs_w;
T.z_r = g.z_r;
T.z_w = g.z_w;
T.z_u = g.z_u;
T.z_v = g.z_v;

%  If vector rotation is required in the parent grid, interpolate
%  rotation angle (parent to target) and add it to target grid
%  structure.

try
T.parent_angle = roms2roms(NWAgrid, P, T, 'angle', [], Rvector,       ...
                           method, offset, RemoveNaN);
catch
    T.parent_angle = P.angle;
end

%---------------------------------------------------------------------------
%  Create boundary condition Netcdf file.
%---------------------------------------------------------------------------

if (CREATE),

  [status]=c_boundary(S);

%  Set attributes for "bry_time".

  avalue=['seconds since ', datestr(refdate, 'yyyy-mm-dd HH:MM:SS')];
  [status]=nc_attadd(BRYname,'units',avalue,'bry_time');
  
  avalue='gregorian';
  [status]=nc_attadd(BRYname,'calendar',avalue,'bry_time');

%  Set global attribute.

  avalue=[domain];
  [status]=nc_attadd(BRYname,'title',avalue);

  avalue=[source];
  [status]=nc_attadd(BRYname,'source',avalue);

  [status]=nc_attadd(BRYname,'grd_file',GRDname);
  
%  Write out grid data.
  
  for var = VarGrd,
    field = char(var);
    [err.(field)] = nc_write(BRYname, field, T.(field));
  end

end,

%---------------------------------------------------------------------------
%  Interpolate boundary conditions from Mercator data to application grid.
%---------------------------------------------------------------------------

disp(' ');
disp(['***************************************************************************']);
disp(['** Interpolating boundaries conditions from ', source, ' to ', domain, ' grid **']);
disp(['***************************************************************************']);

%  The NWA data has a time coordinate in seconds, which starts
%  on 1-Jan-1900.

time = nc_read(NWAdata,'ocean_time');
ot_units = ncreadatt(NWAdata,'ocean_time','units');
index = strfind(ot_units, 'since');
epoch = datenum(ot_units(index+6:end), 'yyyy-mm-dd HH:MM:SS');

%  Set reference time such that boundary conditions time are in
%  "seconds since 2000-01-01 00:00:00".

% ref_time = (datenum('01-Jan-2000')-datenum('01-Jan-1900'))*86400;
ref_time = (refdate - epoch)*86400;

%  Determine dataset time record to process.

StrRec = find(time == (StrDay-epoch)*86400);
if strcmp(datatype, 'daily')
    EndRec = StrRec;
else
    EndRec = find(time == (EndDay-epoch)*86400);
end

if (isempty(StrRec)),
  error(['  Unable to find starting date in dataset: ', datestr(Tstr)]);
end
if (isempty(EndRec)),
  error(['  Unable to find ending date in dataset: ', datestr(Tend)]);
end

for Rec = StrRec:EndRec,

  mydate = datestr(epoch+time(Rec)/86400);

  disp(' ')
  disp(['** Processing: ',mydate,' **']);

%  Interpolate boundary conditions.

  B = obc_roms2roms(NWAdata, P, T, VarBry, Rec, OBC,                  ...
                    method, offset, RemoveNaN);

%  Extract 3D momentum from boundary structure, B.  

  for var = {'west','east','south','north'},
    edge = char(var);
    ufield = strcat('u','_',edge);
    vfield = strcat('v','_',edge);
    if (OBC.(edge)),
      u.(edge) = B.(ufield);
      v.(edge) = B.(vfield);
    end
  end

%  Set Target Grid vertical level thicknesses, Hz.  We have the
%  choice of using time dependent values (zeta ~= 0) or unperturbed
%  depths (zeta = 0).
  
  if (TimeDependent),
    zeta = roms2roms(NWAdata, P, T, 'zeta', Rec, Rvector,             ...
                     method, offset, RemoveNaN);

    N = S.N;
    igrid = 5;
    [z_w] = set_depth(T.Vtransform, T.Vstretching,                    ...
                      T.theta_s, T.theta_b, T.hc, N,                  ...
                      igrid, T.h, zeta, report);

    Hz = z_w(:,:,2:N+1) -z_w(:,:,1:N);
  else
    Hz = T.Hz;
  end

%  Vertically integrate 3D momentum to compute (ubar,vbar).
  
  [ubar,vbar] = uv_barotropic(u, v, Hz, S.boundary);

%  Load lateral boundary 2D momentum (ubar,vbar) to structure.

  for var = {'west','east','south','north'},
    edge = char(var);
    ufield = strcat('ubar','_',edge);
    vfield = strcat('vbar','_',edge);
    if (OBC.(edge)),
      B.(ufield) = ubar.(edge);
      B.(vfield) = vbar.(edge);
    end
  end

%  Set boundary conditions time (seconds since 2000-01-01 00:00:00).

  B.bry_time = time(Rec) - ref_time;
  if B.bry_time < 0
      B.bry_time = 0;
  end
  
%  Write out boundary conditions.

  if (WRITE),

    disp(' ');

    BryRec = BryRec+1;

    varlist = fieldnames(B)';
    
    for var = varlist,
      field = char(var);
      [err.(field)] = nc_write(BRYname, field, B.(field), BryRec);
    end

  end

%  Process next boundary record. If processing OpenDAP files, force Java
%  garbage collection.

%   [~,url,~] = nc_interface(NWAdata);
%   if (url),
%     java.lang.System.gc
%   end

end

end % di

rmpath(genpath(roms_matlab));