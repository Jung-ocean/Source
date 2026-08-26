%
%  D_INITIAL:  Driver script to create a ROMS initial conditions file.
%
%  This a user modifiable script that can be used to prepare ROMS initial
%  conditions NetCDF file.  It sets-up all the necessary parameters and
%  variables. USERS can use this as a prototype for their application.
%
%  This version extends d_initial_Oregon_1km_LiveOcean.m to also define
%  and populate the Spitz biology model tracers (NO3, NH4, DON, DetN,
%  Bacteria, Phytoplankton, Microzooplankton, Chlorophyll, DetC, DOC,
%  Mesozooplankton, Silica, Diatoms, LDetN, LDetC, LDetS, ChlD) using
%  c_biology_spitz.m.
%

% svn $Id$
%=========================================================================%
%  Copyright (c) 2002-2025 The ROMS Group                                 %
%    Licensed under a MIT/X style license                                 %
%    See License_ROMS.md                            Hernan G. Arango      %
%=========================================================================%
roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);

%  Set input/output NetCDF files.

 my_root = './';

 domain = 'Oregon_1km';
 g = grd(domain);
 refdate = datenum(2024,1,1);

 GRDname = g.grd_file;
%  OAname  = fullfile(my_root, 'Data/OA',      'oa4_lev94_feb.nc');
%INIname = fullfile(my_root, 'Data/netcdf3', 'damee4_levfeb_b.nc');
 INIname = ['initial_', domain, '_LiveOcean_bio.nc'];

%  Set local variables.

 OA_INTERPOLATE = 0;               % switch to interpolate from OA fields
 R2R = 1;                          % ROMS 2 ROMS interpolation
 R2R_source_file = '/data/jungjih/Models/LiveOcean/daily/ocean_avg_0001.nc';
 R2R_source_grid = grd('LiveOcean');

 method='linear';                  % linear interpolation
%  method='spline';                  % spline interpolation

%  Biology tracer variables (Spitz biology model). Any of these not
%  found (case-insensitive) in the R2R donor file are initialized to
%  zero.

 bio = spitz_bio_vars();
 BioVars = {bio.name};

%  Donor variable name aliases: this R2R donor (a BIO_FENNEL-style
%  application) splits detritus into small/large N and C pools under
%  different names than the Spitz model, and lumps all zooplankton into
%  a single pool. 
%  Per Peterson & Miller (1977), the winter coastal %  zooplankton 
%  assemblage (Mesocalanus tenuicornis, Paracalanus parvus, 
%  Ctenocalanus vanus, Clausocalanus spp., Acartia tonsa, Corycaeus
%  anglicus) is entirely calanoid/cyclopoid copepods, i.e. mesozooplankton
%  size class (0.2-20 mm; Sieburth et al. 1978), not microzooplankton
%  (20-200 micron protists/nauplii). So the donor's lumped 'zooplankton'
%  is mapped entirely to Mesozooplankton, leaving Microzooplankton at
%  zero. Each row is {target name, donor name}; tried before falling
%  back to a same-name (case-insensitive) match.

 DonorAliases = {'DetN',            'SdetritusN';                       ...
                 'LDetN',           'LdetritusN';                       ...
                 'DetC',            'SdetritusC';                       ...
                 'LDetC',           'LdetritusC';                       ...
                 'Mesozooplankton', 'zooplankton'};

%  Silica, Diatoms, LDetS, and ChlD have no direct or aliased donor
%  variable (this donor's Fennel-type biology has no silicate cycle and
%  no diatom/non-diatom split).  They are instead derived below from
%  donor fields using literature-based ratios for the Oregon shelf:
%
%    N:Si molar ratio (Corwith and Wheeler, "El Nino related variations
%    in nutrient and chlorophyll distributions off Oregon"): 0.79 under
%    normal conditions, 0.97 under El Nino conditions.  This
%    application's initial time (1-Jan-2024, see 'refdate' above) falls
%    within the strong 2023-2024 El Nino (DJF 2023-24 ONI ~ +1.8 to
%    +2.0), so the El Nino ratio is used to derive Silica from NO3 and
%    LDetS from LDetN.
%
%    Winter diatom fraction of total phytoplankton carbon biomass off
%    central Oregon (Du and Peterson, 2009, "Seasonal Cycle of
%    Phytoplankton Community Composition in the Coastal Upwelling System
%    Off Central Oregon"): diatoms averaged 58.8% of total phytoplankton
%    carbon biomass in winter.  Applied here to the donor's nitrogen-
%    based 'phytoplankton' to split it into Diatoms and the (reduced)
%    Phytoplankton pool, assuming diatoms and other phytoplankton share
%    similar C:N ratios.
%
%    ChlD (diatom chlorophyll) reuses the donor's own diagnosed
%    Chlorophyll:Phytoplankton (Chl:N) ratio, applied to Diatoms; the
%    (reduced) Chlorophyll pool is rescaled with the same ratio so that
%    Chlorophyll + ChlD conserves the donor's total chlorophyll.

 N_Si_ratio      = 0.97;            % N:Si molar ratio, El Nino conditions
 Si_N_ratio      = 1/N_Si_ratio;    % Si:N molar ratio applied to NO3, LDetN

 diatom_fraction = 0.588;           % winter diatom fraction of phytoplankton

%--------------------------------------------------------------------------
%  Set application parameters in structure array, S.
%--------------------------------------------------------------------------

%  Initial conditions output file name.

S.ncname = INIname;

%  Spherical grid switch.
%
%            [0] Cartesian grid
%            [1] Spherical grid

S.spherical = 1;

%  Number of interior RHO-points (Lm, Mm) in the X- and Y-directions. These
%  are the values specified in ROMS input script.

S.Lm = size(g.lon_rho,1)-2;
S.Mm = size(g.lon_rho,2)-2;

%  Number of vertical levels (N) at RHO-points (center grid cell).

S.N = g.N;

%  Number of total active and passive tracers. Usually, NT=2 for potential
%  temperature and salinity.

S.NT = 2;

%  Set vertical stretching parameters. These values are specified in ROMS
%  input script.

%  Vertical transfomation equation (Vtransform).
%    (Check  https://www.myroms.org/wiki/index.php/Vertical_S-coordinate)
%
%            [1] Original tranformation equation
%            [2] New transformation equation

S.Vtransform = g.Vtransform;

%  Vertical stretching function (Vstretching).
%    (Check  https://www.myroms.org/wiki/index.php/Vertical_S-coordinate)
%
%            [1] Original function (Song and Haidvogel, 1994)
%            [2] A. Shchepetkin function
%            [3] R. Geyer function

S.Vstretching = g.Vstretching;

%  Vertical stretching parameters:
%
%            tetha_s:  S-coordinate surface control parameter.
%            tetha_b:  S-coordinate bottom control parameter.
%            Tcline:   S-coordinate surface/bottom stretching width (m)

S.theta_s = g.theta_s;
S.theta_b = g.theta_b;
S.Tcline  = g.Tcline;

S.hc = S.Tcline;

%--------------------------------------------------------------------------
%  Create initial condition Netcdf file.
%--------------------------------------------------------------------------

[~]=c_initial(S);

%  Define the Spitz biology model tracer variables.

[~]=c_biology_spitz(S);

%  Set attributes for "ocean_time".

avalue=['seconds since ', datestr(refdate, 'yyyy-mm-dd HH:MM:SS')];
[~]=nc_attadd(INIname,'units',avalue,'ocean_time');

% avalue='360.0 days in every year';
% [~]=nc_attadd(INIname,'calendar',avalue,'ocean_time');

%--------------------------------------------------------------------------
%  Set grid variables.
%--------------------------------------------------------------------------

V=nc_vnames(GRDname);
nvars=length(V.Variables);

%  Horizontal grid variables. Read in for input GRID NetCDF file.

if (S.spherical),
  S.lon_rho = nc_read(GRDname, 'lon_rho');
  S.lat_rho = nc_read(GRDname, 'lat_rho');

  S.lon_u   = nc_read(GRDname, 'lon_u');
  S.lat_u   = nc_read(GRDname, 'lat_u');

  S.lon_v   = nc_read(GRDname, 'lon_v');
  S.lat_v   = nc_read(GRDname, 'lat_v');
else
  S.x_rho   = nc_read(GRDname, 'x_rho');
  S.y_rho   = nc_read(GRDname, 'y_rho');

  S.x_u     = nc_read(GRDname, 'x_u');
  S.y_u     = nc_read(GRDname, 'y_u');

  S.x_v     = nc_read(GRDname, 'x_v');
  S.y_v     = nc_read(GRDname, 'y_v');
end

%  Read in Land/Sea mask, if appropriate.

for n=1:nvars,
  name=char(V.Variables(n).Name);
  switch (name),
    case 'mask_rho'
      S.mask_rho = nc_read(GRDname, 'mask_rho');
    case 'mask_u'
      S.mask_u   = nc_read(GRDname, 'mask_u');
    case 'mask_v'
      S.mask_v   = nc_read(GRDname, 'mask_v');
  end,
end,


%  Bathymetry.

S.h = nc_read(GRDname, 'h');

%  Set vertical grid variables.

[S.s_rho, S.Cs_r]=stretching(S.Vstretching, ...
                             S.theta_s, S.theta_b, S.hc, S.N,           ...
			     0, 1);

[S.s_w,   S.Cs_w]=stretching(S.Vstretching, ...
                             S.theta_s, S.theta_b, S.hc, S.N,           ...
			     1, 1);

%--------------------------------------------------------------------------
%  Set zero initial conditions.
%--------------------------------------------------------------------------

Lr = S.Lm+2;   Lu = Lr-1;   Lv = Lr;
Mr = S.Mm+2;   Mu = Mr;     Mv = Mr-1;

S.zeta = zeros([Lr Mr]);
S.ubar = zeros([Lu Mu]);
S.vbar = zeros([Lv Mv]);
S.u    = zeros([Lu Mu S.N]);
S.v    = zeros([Lv Mv S.N]);
S.temp = zeros([Lr Mr S.N]);
S.salt = zeros([Lr Mr S.N]);

%  Initialize biology tracers to zero. Any variable found in the R2R
%  donor file below will overwrite these zeros with interpolated data.

for vi = 1:length(BioVars)
  S.(BioVars{vi}) = zeros([Lr Mr S.N]);
end

%  If Land/Sea masking arrays are not found, initialize them to unity.

if (~isfield(S, 'mask_rho')),  S.mask_rho = ones([Lr Mr]);  end,
if (~isfield(S, 'mask_u'  )),  S.mask_u   = ones([Lu Mu]);  end,
if (~isfield(S, 'mask_v'  )),  S.mask_v   = ones([Lv Mv]);  end,

%--------------------------------------------------------------------------
%  Write out grid variables.
%--------------------------------------------------------------------------

[~]=nc_write(INIname,   'spherical',   S.spherical);

[~]=nc_write(INIname,   'Vtransform',  S.Vtransform);
[~]=nc_write(INIname,   'Vstretching', S.Vstretching);
[~]=nc_write(INIname,   'theta_s',     S.theta_s);
[~]=nc_write(INIname,   'theta_b',     S.theta_b);
[~]=nc_write(INIname,   'Tcline',      S.Tcline);
[~]=nc_write(INIname,   'hc',          S.hc);

[~]=nc_write(INIname,   's_rho',       S.s_rho);
[~]=nc_write(INIname,   's_w',         S.s_w);
[~]=nc_write(INIname,   'Cs_r',        S.Cs_r);
[~]=nc_write(INIname,   'Cs_w',        S.Cs_w);

[~]=nc_write(INIname,   'h',           S.h);

if (S.spherical),
  [~]=nc_write(INIname, 'lon_rho',     S.lon_rho);
  [~]=nc_write(INIname, 'lat_rho',     S.lat_rho);
  [~]=nc_write(INIname, 'lon_u',       S.lon_u);
  [~]=nc_write(INIname, 'lat_u',       S.lat_u);
  [~]=nc_write(INIname, 'lon_v',       S.lon_v);
  [~]=nc_write(INIname, 'lat_v',       S.lat_v);
else
  [~]=nc_write(INIname, 'x_rho',       S.x_rho);
  [~]=nc_write(INIname, 'y_rho',       S.y_rho);
  [~]=nc_write(INIname, 'x_u',         S.x_u);
  [~]=nc_write(INIname, 'y_u',         S.y_u);
  [~]=nc_write(INIname, 'x_v',         S.x_v);
  [~]=nc_write(INIname, 'y_v',         S.y_v);
end

%--------------------------------------------------------------------------
%  Compute depths at horizontal and vertical RHO-points.
%--------------------------------------------------------------------------

igrid = 1;

[z_r] = set_depth(S.Vtransform, S.Vstretching,                          ...
                  S.theta_s, S.theta_b, S.hc, S.N,                      ...
                  igrid, S.h, S.zeta);

%--------------------------------------------------------------------------
%  Interpolate OA of temperature and salinity from standard levels to
%  model depths.
%--------------------------------------------------------------------------

if (OA_INTERPOLATE),

  disp(' ')
  disp('Interpolating from OA fields, please wait ...');

  InpRec = 1;

  Zoa=nc_read(OAname, 'zout');

  oa_temp=nc_read(OAname, 'temp', InpRec);
  oa_salt=nc_read(OAname, 'salt', InpRec);

  for j=1:Mr,
    for i=1:Lr,
      Zroms = squeeze(z_r(i,j,:));
      Toa   = squeeze(oa_temp(i,j,:));
      Soa   = squeeze(oa_salt(i,j,:));

      S.temp(i,j,:) = interp1(Zoa, Toa, Zroms, method);
      S.salt(i,j,:) = interp1(Zoa, Soa, Zroms, method);
    end,
  end,

end,

if R2R == 1
    Dname = R2R_source_file; % Donor file
    D = R2R_source_grid; % Donor
    R = g; % Receiver
    Tindex = 1;
    Rvector = false;
    Vnames = {'zeta', 'u', 'v', 'temp', 'salt'};
    for vi = 1:length(Vnames)
        Vname = Vnames{vi};
        V = roms2roms(Dname,D,R,Vname,Tindex,Rvector);
        eval(['S.', Vname, ' = V']);
    end

    %  Biology tracers: interpolate only for variables that exist by
    %  name in the R2R donor file (ignoring upper/lower case); otherwise
    %  leave the zero initial value set above.  When a matching donor
    %  variable is found, its 'units' attribute is compared against the
    %  target units for this application; if they differ, the data is
    %  converted, and the conversion is reported below.

    DonorV = nc_vnames(Dname);
    DonorVarNames = {DonorV.Variables.Name};

    disp(' ')
    disp('Biology tracer initial conditions from R2R donor file:')

    for vi = 1:length(bio)
        Vname       = bio(vi).name;
        TargetUnits = bio(vi).units;

        %  Try an explicit donor name alias first, then fall back to a
        %  same-name (case-insensitive) match.

        alias = find(strcmpi(DonorAliases(:,1), Vname), 1);
        if (~isempty(alias))
            candidates = {DonorAliases{alias,2}, Vname};
        else
            candidates = {Vname};
        end

        match = [];
        for ci = 1:length(candidates)
            match = find(strcmpi(DonorVarNames, candidates{ci}), 1);
            if (~isempty(match)), break, end
        end

        if (~isempty(match))
            DonorName  = DonorVarNames{match};
            Vdata      = roms2roms(Dname,D,R,DonorName,Tindex,Rvector);
            DonorUnits = nc_getatt(Dname, 'units', DonorName);

            if (strcmpi(strtrim(DonorUnits), strtrim(TargetUnits))),
                disp(['  ', Vname, ': from donor variable ''',          ...
                      DonorName, ''' (units match: ', TargetUnits, ')']);
            else
                factor = bio_unit_factor(DonorUnits, TargetUnits);
                if (isnan(factor)),
                    disp(['  ', Vname,                                  ...
                          ': WARNING - donor variable ''', DonorName,   ...
                          ''' units (''', DonorUnits, ''') could not ', ...
                          'be converted to (''', TargetUnits, '''); ',  ...
                          'using raw donor values.']);
                else
                    disp(['  ', Vname, ': from donor variable ''',      ...
                          DonorName, ''', converting units from ''',    ...
                          DonorUnits, ''' to ''', TargetUnits, ''' ',   ...
                          '(factor = ', num2str(factor), ')']);
                    Vdata = Vdata*factor;
                end
            end

            S.(Vname) = Vdata;
        else
            disp(['  ', Vname, ': no matching donor variable found, ',  ...
                  'initializing to zero.']);
        end
    end

    %  Derive Silica, Diatoms, LDetS, and ChlD from the donor fields
    %  matched above (NO3, LDetN, Phytoplankton, Chlorophyll), using the
    %  literature-based ratios documented above.

    disp(' ')
    disp(['Deriving Silica, Diatoms, LDetS, and ChlD from donor ',       ...
          'fields (no direct donor match):'])

    S.Silica = S.NO3   * Si_N_ratio;
    S.LDetS  = S.LDetN * Si_N_ratio;
    disp(['  Silica = NO3 * Si:N (', num2str(Si_N_ratio),               ...
          '), LDetS = LDetN * Si:N']);

    DonorPhytoN = S.Phytoplankton;             % full donor phytoplankton
    DonorChl    = S.Chlorophyll;               % full donor chlorophyll

    S.Diatoms       = diatom_fraction*DonorPhytoN;
    S.Phytoplankton = (1-diatom_fraction)*DonorPhytoN;
    disp(['  Diatoms = ', num2str(diatom_fraction), ' * donor ',        ...
          'phytoplankton; Phytoplankton = remaining ',                  ...
          num2str(1-diatom_fraction)]);

    ChlNratio = zeros(size(DonorPhytoN));
    haveN = DonorPhytoN > 0;
    ChlNratio(haveN) = DonorChl(haveN)./DonorPhytoN(haveN);

    S.ChlD        = S.Diatoms.*ChlNratio;
    S.Chlorophyll = S.Phytoplankton.*ChlNratio;
    disp(['  ChlD and Chlorophyll = Diatoms/Phytoplankton times the ',  ...
          'donor''s own diagnosed Chlorophyll:Phytoplankton ratio']);
end
% Calculate ubar and vbar
z_w = zlevs(g.h,S.zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
dz = z_w(:,:,2:end) - z_w(:,:,1:end-1);
dzu = 0.5*(dz(1:end-1,:,:)+dz(2:end,:,:));
dzv = 0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));
hu = sum(dzu.*S.u,3);
hv = sum(dzv.*S.v,3);
D_u = sum(dzu,3);
D_v = sum(dzv,3);
ubar = hu./D_u;
vbar = hv./D_v;

S.ubar = ubar;
S.vbar = vbar;

%---------------------------------------------------------------------------
%  Write out initial conditions.
%---------------------------------------------------------------------------

IniRec = 1;                               % NetCDF time record

S.ocean_time = 0.0*86400;                % initial conditions time (s)

[~]=nc_write(INIname, 'ocean_time', S.ocean_time, IniRec);

[~]=nc_write(INIname, 'zeta', S.zeta, IniRec);
[~]=nc_write(INIname, 'ubar', S.ubar, IniRec);
[~]=nc_write(INIname, 'vbar', S.vbar, IniRec);
[~]=nc_write(INIname, 'u',    S.u,    IniRec);
[~]=nc_write(INIname, 'v',    S.v,    IniRec);
[~]=nc_write(INIname, 'temp', S.temp, IniRec);
[~]=nc_write(INIname, 'salt', S.salt, IniRec);

for vi = 1:length(BioVars)
  [~]=nc_write(INIname, BioVars{vi}, S.(BioVars{vi}), IniRec);
end

rmpath(this_dir);
rmpath(genpath(roms_matlab));
