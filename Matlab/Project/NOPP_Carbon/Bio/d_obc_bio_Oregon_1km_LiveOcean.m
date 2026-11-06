%
%  D_OBC_BIO:  Driver script to create ROMS biology open boundary files
%
%  Creates one open boundary conditions NetCDF file per Spitz biology
%  model tracer, e.g. boundary_Oregon_1km_bio_Chlorophyll.nc, by
%  interpolating the biology fields of the LiveOcean donor onto the
%  application grid edges.
%
%  The file structure follows the physical boundary file written by
%  d_obc_roms2roms_Oregon_1km_LiveOcean.m (same dimension names, the
%  same '<variable>_<edge>' naming, the same 'bry_time' record
%  dimension, single precision), so the biology files can be listed
%  alongside the physical boundary file in the ROMS input script.
%
%  The donor runs a BIO_FENNEL-type biology, so only 8 of its fields are
%  interpolated; the remaining Spitz tracers are derived from them.  See
%  spitz_bio_from_donor.m for the plan, which is shared with the initial
%  conditions driver.
%

clear; clc
%==========================================================================
roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);

yyyy = 2024;

source = 'LiveOcean';
R2R_source_grid = grd('LiveOcean');
datatype = 'daily';

domain = 'Oregon_1km';
g = grd(domain);
refdate = datenum(2024,1,1);
GRDname = g.grd_file;

%  Output directory and file name prefix. One file per tracer:
%  <BIOdir>/<BRYprefix><tracer>.nc
%
%  When run by run_bio_bry_parallel.sh each session works in its own
%  chunk directory, so BIO_BRY_OUTDIR overrides BIOdir there.

BIOdir = ['/data/jungjih/Project/NOPP_Carbon/', domain,                 ...
          '/Setups/Bio_LiveOcean'];

env_outdir = getenv('BIO_BRY_OUTDIR');
if (~isempty(env_outdir)),
  BIOdir = env_outdir;
end

if (~exist(BIOdir, 'dir')), mkdir(BIOdir); end

BRYprefix = fullfile(BIOdir, ['boundary_', domain, '_bio_']);

%  Days to process.
%
%  A full 366-day run takes roughly 21 hours in a single session.  To
%  spread it over several sessions running at the same time, set the
%  environment variable BIO_BRY_DAYS before starting MATLAB and give
%  each session its own working directory, then concatenate the chunks
%  along 'bry_time' with ncrcat.  run_bio_bry_parallel.sh does this.
%  The environment variable survives the 'clear' above, so it can be set
%  from outside without editing this script.

DayList = 1:366;

env_days = getenv('BIO_BRY_DAYS');            % e.g. '1:61'
if (~isempty(env_days)),
  DayList = eval(env_days);                                            %#ok<EVLDCL>
  disp(['Day range from BIO_BRY_DAYS: ', env_days]);
end

%  Logical switch to create the biology boundary files.  Set it to false
%  to append to files that already exist, which allows a long run to be
%  resumed: the new records are appended after the ones already written.
%  For example, after a run that stopped partway, set
%
%     CREATE_FILES = false;
%     DayList      = 121:366;
%
%  Note this is for resuming within one output directory.  Sessions
%  running in parallel must each create their own files in their own
%  directory, otherwise they overwrite each other's records.

CREATE_FILES = true;

env_create = getenv('BIO_BRY_CREATE');        % '0' to append instead
if (~isempty(env_create)),
  CREATE_FILES = ~strcmp(env_create, '0');
end

%  Ratios used to build the biology tracers. Override any field here to
%  depart from the shared defaults, e.g.
%
%     P.Bio_background = 1.0e-1;

P = spitz_bio_params();

%  Spitz biology tracers, and the donor fields they are built from.

bio = spitz_bio_vars();
BioVars = {bio.name};

DonorMap = {'NO3',           'NO3';                                     ...
            'NH4',           'NH4';                                     ...
            'SdetritusN',    'DetN';                                    ...
            'SdetritusC',    'DetC';                                    ...
            'LdetritusN',    'LDetN';                                   ...
            'LdetritusC',    'LDetC';                                   ...
            'phytoplankton', 'Phytoplankton';                           ...
            'zooplankton',   'Mesozooplankton'};

DonorBioVars = DonorMap(:,1)';

%  Set switches for boundary segments to process.

OBC.west  = true;          % process western  boundary segment
OBC.east  = false;         % process eastern  boundary segment
OBC.south = true;          % process southern boundary segment
OBC.north = true;          % process northern boundary segment

%  Set interpolation parameters.

method    = 'linear';          % linear interpolation
offset    = 10;                % number of extra points for sampling
RemoveNaN = true;              % remove NaN with nearest-neighbor
Rvector   = false;             % interpolate vectors to RHO-points

%--------------------------------------------------------------------------
%  Set application parameters in structure array, S.
%--------------------------------------------------------------------------

[Lr,Mr] = size(nc_read(GRDname,'h'));

S.spherical   = 1;          % spherical grid
S.Lm          = Lr-2;       % number of interior RHO-points, X-direction
S.Mm          = Mr-2;       % number of interior RHO-points, Y-direction
S.N           = g.N;        % number of vertical levels at RHO-points
S.NT          = 2;          % total number of tracers

S.Vtransform  = g.Vtransform;
S.Vstretching = g.Vstretching;

S.theta_s     = g.theta_s;
S.theta_b     = g.theta_b;
S.Tcline      = g.Tcline;
S.hc          = S.Tcline;

S.boundary(1) = OBC.west;
S.boundary(2) = OBC.east;
S.boundary(3) = OBC.south;
S.boundary(4) = OBC.north;

%  Grid variables written to every biology boundary file.

VarGrd = {'spherical',                                                  ...
          'Vtransform', 'Vstretching',                                  ...
          'theta_s', 'theta_b', 'Tcline', 'hc',                         ...
          's_rho', 'Cs_r', 's_w', 'Cs_w'};

if (S.spherical),
  if (OBC.west),  VarGrd = [VarGrd, 'lon_rho_west',  'lat_rho_west'];  end
  if (OBC.east),  VarGrd = [VarGrd, 'lon_rho_east',  'lat_rho_east'];  end
  if (OBC.south), VarGrd = [VarGrd, 'lon_rho_south', 'lat_rho_south']; end
  if (OBC.north), VarGrd = [VarGrd, 'lon_rho_north', 'lat_rho_north']; end
else
  if (OBC.west),  VarGrd = [VarGrd, 'x_rho_west',  'y_rho_west'];  end
  if (OBC.east),  VarGrd = [VarGrd, 'x_rho_east',  'y_rho_east'];  end
  if (OBC.south), VarGrd = [VarGrd, 'x_rho_south', 'y_rho_south']; end
  if (OBC.north), VarGrd = [VarGrd, 'x_rho_north', 'y_rho_north']; end
end

%--------------------------------------------------------------------------
%  Get parent and target grid structures.
%--------------------------------------------------------------------------

P_grid = R2R_source_grid;                % parent (donor) grid

N = P_grid.N;
P_grid.z_r(:,:,N) = 0;
P_grid.z_u(:,:,N) = 0;
P_grid.z_v(:,:,N) = 0;

T = get_roms_grid(GRDname, S);           % target grid

T.s_rho = g.s_rho;   T.Cs_r = g.Cs_r;
T.s_w   = g.s_w;     T.Cs_w = g.Cs_w;
T.z_r   = g.z_r;     T.z_w  = g.z_w;
T.z_u   = g.z_u;     T.z_v  = g.z_v;

%--------------------------------------------------------------------------
%  Check the donor units once, and build conversion factors.
%--------------------------------------------------------------------------

FirstData = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_',         ...
             num2str(DayList(1), '%04i'), '.nc'];

DonorV = nc_vnames(FirstData);
DonorVarNames = {DonorV.Variables.Name};

disp(' ')
disp('Checking donor biology units:')

factors = struct();
for vi = 1:size(DonorMap,1)
  dn          = DonorMap{vi,1};
  ui          = find(strcmp(BioVars, DonorMap{vi,2}), 1);
  TargetUnits = bio(ui).units;

  match = find(strcmpi(DonorVarNames, dn), 1);
  if (isempty(match)),
    error(['D_OBC_BIO - donor variable not found: ', dn]);
  end

  DonorName  = DonorVarNames{match};
  DonorUnits = nc_getatt(FirstData, 'units', DonorName);

  if (strcmpi(strtrim(DonorUnits), strtrim(TargetUnits))),
    factors.(dn) = 1;
    disp(['  ', DonorName, ': units OK (', TargetUnits, ')']);
  else
    f = bio_unit_factor(DonorUnits, TargetUnits);
    if (isnan(f)),
      factors.(dn) = 1;
      disp(['  ', DonorName, ': WARNING - units (''', DonorUnits,       ...
            ''') could not be converted to (''', TargetUnits,           ...
            '''); using raw donor values.']);
    else
      factors.(dn) = f;
      disp(['  ', DonorName, ': converting units ''', DonorUnits,       ...
            ''' -> ''', TargetUnits, ''' (factor = ', num2str(f), ')']);
    end
  end
end

%--------------------------------------------------------------------------
%  Time reference of the donor files.
%--------------------------------------------------------------------------

ot_units = ncreadatt(FirstData,'ocean_time','units');
index    = strfind(ot_units, 'since');
epoch    = datenum(ot_units(index+6:end), 'yyyy-mm-dd HH:MM:SS');

ref_time = (refdate - epoch)*86400;

%--------------------------------------------------------------------------
%  Process each day.
%--------------------------------------------------------------------------

disp(' ');
disp('***************************************************************');
disp(['** Biology boundary conditions from ', source, ' to ', domain]);
disp('***************************************************************');

%  Initialize the unlimited dimension record counter.  When appending to
%  existing files, continue after the records already written.

if (CREATE_FILES),
  BryRec = 0;
else
  BryRec = length(nc_read([BRYprefix, bio(1).name, '.nc'], 'bry_time'));
  disp(' ')
  disp(['Appending to existing biology boundary files after record ',   ...
        num2str(BryRec), '.']);
end

for di = DayList

  fstr    = num2str(di, '%04i');
  NWAdata = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_', fstr, '.nc'];

  CREATE = CREATE_FILES && (di == DayList(1));

  StrDay = datenum(yyyy,1,1,12,0,0)+di-1;

%  Create the biology boundary files on the first pass.

  if (CREATE),
    disp(' ')
    disp('Creating biology boundary files ...');

    for vi = 1:length(bio)
      S.ncname        = [BRYprefix, bio(vi).name, '.nc'];
      S.bio_name      = bio(vi).name;
      S.bio_long_name = bio(vi).long_name;
      S.bio_units     = bio(vi).units;

      [~]=c_boundary_spitz(S);

      avalue=['seconds since ', datestr(refdate, 'yyyy-mm-dd HH:MM:SS')];
      [~]=nc_attadd(S.ncname,'units',avalue,'bry_time');

      avalue='gregorian';
      [~]=nc_attadd(S.ncname,'calendar',avalue,'bry_time');

      [~]=nc_attadd(S.ncname,'title',domain);
      [~]=nc_attadd(S.ncname,'source',source);
      [~]=nc_attadd(S.ncname,'grd_file',GRDname);

%  Write out grid data.

      for var = VarGrd,
        field = char(var);
        [~]=nc_write(S.ncname, field, T.(field));
      end

      disp(['  created ', S.ncname]);
    end
  end

%  Determine the donor time record to process.

  time   = nc_read(NWAdata,'ocean_time');
  StrRec = find(time == (StrDay-epoch)*86400);

  if (isempty(StrRec)),
    error(['  Unable to find date in dataset: ', datestr(StrDay)]);
  end

  if strcmp(datatype, 'daily')
    EndRec = StrRec;
  else
    EndRec = StrRec;
  end

  for Rec = StrRec:EndRec,

    mydate = datestr(epoch+time(Rec)/86400);

    disp(' ')
    disp(['** Processing: ', mydate, '  (file ', fstr, ') **']);

%  Interpolate the donor biology fields to the grid edges.

    Bd = obc_roms2roms(NWAdata, P_grid, T, DonorBioVars, Rec, OBC,      ...
                       method, offset, RemoveNaN);

%  Build the Spitz tracers from them.

    Bb = make_spitz_bio_obc(Bd, OBC, P, factors);

%  Boundary conditions time.

    bry_time = time(Rec) - ref_time;
    if bry_time < 0
      bry_time = 0;
    end

%  Write one record into each tracer's file.

    BryRec = BryRec+1;

    for vi = 1:length(bio)
      Vname   = bio(vi).name;
      BRYname = [BRYprefix, Vname, '.nc'];

      [~]=nc_write(BRYname, 'bry_time', bry_time, BryRec);

      for var = {'west','east','south','north'},
        edge = char(var);
        if (~OBC.(edge)), continue, end
        field = [Vname, '_', edge];
        [~]=nc_write(BRYname, field, Bb.(field), BryRec);
      end
    end

  end

end

disp(' ')
disp(['Done. Wrote ', num2str(BryRec), ' records to ',                  ...
      num2str(length(bio)), ' biology boundary files.']);

rmpath(this_dir);
rmpath(genpath(roms_matlab));
