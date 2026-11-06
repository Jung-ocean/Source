function B = make_spitz_bio(Dname, D, R, Tindex, P)

%
% MAKE_SPITZ_BIO:  Builds Spitz biology initial conditions from a donor
%
% B = make_spitz_bio(Dname, D, R, Tindex, P)
%
% Interpolates the biology fields of a donor ROMS file onto the receiver
% grid and builds the 17 Spitz biology model tracers from them.  The
% donor (LiveOcean) runs a BIO_FENNEL-type biology, which carries an
% equivalent pool for some Spitz tracers, a single lumped pool where the
% Spitz model resolves two, and nothing at all for the dissolved organic
% matter and bacteria compartments.  The plan is:
%
%    Used as is from the donor:
%      NO3   <- NO3            NH4   <- NH4
%      DetN  <- SdetritusN     DetC  <- SdetritusC
%      LDetN <- LdetritusN     LDetC <- LdetritusC
%
%    Split of a single lumped donor pool:
%      Phytoplankton / Diatoms          P.phyto_diatom_split of
%                                         donor 'phytoplankton'
%      Microzooplankton / Mesozoo.      P.zoo_micro_split of
%                                         donor 'zooplankton'
%
%    Derived from the pools above:
%      Chlorophyll = P.ChlN_phyto  (Chl:N) x Phytoplankton
%      ChlD        = P.ChlN_diatom (Chl:N) x Diatoms
%      Silica      = P.SiN_ratio   (Si:N)  x NO3
%      LDetS       = P.SiN_ratio   (Si:N)  x LDetN
%      DOC         = P.CN_ratio    (C:N)   x DON
%      Bacteria    = P.Bacteria_fraction   x Phytoplankton
%
%    No donor counterpart, set to a small non-zero background:
%      DON         (a zero value would prevent growth)
%
% DON, Bacteria, DOC, and the split zooplankton pools all adjust quickly
% once the model spins up, so their exact initial split matters little.
% Bacteria is floored at the same small background value as DON so it
% cannot start at zero anywhere.
%
% Note the donor's own 'chlorophyll' field is intentionally NOT used:
% Chlorophyll is rebuilt from the split Phytoplankton pool using the
% Chl:N ratio above, so that Chlorophyll and ChlD stay consistent with
% their respective nitrogen pools.
%
% Donor variable names are matched ignoring upper/lower case, and each
% field's 'units' attribute is checked against the units of the Spitz
% tracer it feeds, converting the data when they differ.
%
% On Input:
%
%    Dname       Donor NetCDF file name (string)
%    D           Donor grid structure    (struct array, from grd/get_roms_grid)
%    R           Receiver grid structure (struct array, from grd/get_roms_grid)
%    Tindex      Time record index to read from the donor (scalar)
%    P           Ratios structure (optional; default spitz_bio_params)
%
% On Output:
%
%    B           Structure with one field per Spitz biology tracer,
%                  each [Lr Mr N] on the receiver grid
%

if (nargin < 5),
  P = spitz_bio_params();
end

bio = spitz_bio_vars();

%  Receiver grid dimensions, used when a donor field is missing.

Lr = size(R.lon_rho,1);
Mr = size(R.lon_rho,2);
Nr = R.N;

Rvector = false;                 % all tracers live at RHO-points

%--------------------------------------------------------------------------
%  Read the donor biology fields needed by the plan above.
%
%  Column 1 is the donor variable name; column 2 names the Spitz tracer
%  whose units it must match.  Only column 1 is ever looked up in the
%  donor file: the lower-case donor pools ('phytoplankton',
%  'zooplankton') are deliberately distinct from the Spitz tracers they
%  feed ('Phytoplankton', 'Mesozooplankton'), which hold only a fraction
%  of them.
%--------------------------------------------------------------------------

DonorMap = {'NO3',           'NO3';                                     ...
            'NH4',           'NH4';                                     ...
            'SdetritusN',    'DetN';                                    ...
            'SdetritusC',    'DetC';                                    ...
            'LdetritusN',    'LDetN';                                   ...
            'LdetritusC',    'LDetC';                                   ...
            'phytoplankton', 'Phytoplankton';                           ...
            'zooplankton',   'Mesozooplankton'};

DonorV = nc_vnames(Dname);
DonorVarNames = {DonorV.Variables.Name};

disp(' ')
disp('Reading biology fields from donor file:')

for vi = 1:size(DonorMap,1)
  WantName    = DonorMap{vi,1};
  ui          = find(strcmp({bio.name}, DonorMap{vi,2}), 1);
  TargetUnits = bio(ui).units;

  match = find(strcmpi(DonorVarNames, WantName), 1);

  if (isempty(match)),
    Donor.(WantName) = zeros([Lr Mr Nr]);
    disp(['  ', WantName, ': NOT FOUND in donor file, using zeros.']);
    continue
  end

  DonorName  = DonorVarNames{match};
  Vdata      = roms2roms(Dname,D,R,DonorName,Tindex,Rvector);
  DonorUnits = nc_getatt(Dname, 'units', DonorName);

  if (strcmpi(strtrim(DonorUnits), strtrim(TargetUnits))),
    disp(['  ', DonorName, ': units OK (', TargetUnits, ')']);
  else
    factor = bio_unit_factor(DonorUnits, TargetUnits);
    if (isnan(factor)),
      disp(['  ', DonorName, ': WARNING - units (''', DonorUnits,       ...
            ''') could not be converted to (''', TargetUnits,           ...
            '''); using raw donor values.']);
    else
      disp(['  ', DonorName, ': converting units ''', DonorUnits,       ...
            ''' -> ''', TargetUnits, ''' (factor = ',                   ...
            num2str(factor), ')']);
      Vdata = Vdata*factor;
    end
  end

  Donor.(WantName) = Vdata;
end

%--------------------------------------------------------------------------
%  Build the Spitz biology tracers.  The plan is applied by
%  spitz_bio_from_donor, which is shared with the open boundary
%  condition driver so that both are built with identical math.
%--------------------------------------------------------------------------

B = spitz_bio_from_donor(Donor, P, true);

return
