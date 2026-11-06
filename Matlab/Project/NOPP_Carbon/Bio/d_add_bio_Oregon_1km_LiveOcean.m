%
%  D_ADD_BIO:  Driver script to append biology tracers to an existing
%              ROMS initial conditions file.
%
%  This script takes an initial conditions file that already holds the
%  grid and physical variables (zeta, ubar, vbar, u, v, temp, salt),
%  copies it, and appends the Spitz biology model tracers (NO3, NH4,
%  DON, DetN, Bacteria, Phytoplankton, Microzooplankton, Chlorophyll,
%  DetC, DOC, Mesozooplankton, Silica, Diatoms, LDetN, LDetC, LDetS,
%  ChlD) to the copy.  The original file is left untouched, and the
%  physical interpolation is not repeated.
%
%  Run d_initial_Oregon_1km_LiveOcean.m first to build the physical
%  file, then this script to add the biology tracers to a copy of it.
%

roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);

%--------------------------------------------------------------------------
%  Set input/output NetCDF files.
%--------------------------------------------------------------------------

 domain = 'Oregon_1km';
 g = grd(domain);
 refdate = datenum(2024,1,1);

 R2R_source_date = datenum(2024,1,1);
 filenum = R2R_source_date-refdate+1;
 fstr = num2str(filenum, '%04i');

%  Setup directories. The physical initial conditions are read from
%  PHYdir, and everything biology related is written to BIOdir.

 PHYdir = ['/data/jungjih/Project/NOPP_Carbon/', domain,                ...
           '/Setups/Initial_LiveOcean'];
 BIOdir = ['/data/jungjih/Project/NOPP_Carbon/', domain,                ...
           '/Setups/Bio_LiveOcean/hmin_5m'];

 if (~exist(BIOdir, 'dir')), mkdir(BIOdir); end

%  Existing initial conditions file holding the physical variables. It
%  is only read from, never modified.

 PHYname = fullfile(PHYdir, ['initial_', domain, '_LiveOcean_hmin_5m.nc']);

%  Output file: a copy of PHYname with the biology tracers appended.

 INIname = fullfile(BIOdir, ['initial_', domain, '_LiveOcean_hmin_5m_bio.nc']);

%  Donor file supplying the biology fields.

%  R2R_source_file = '/data/jungjih/Models/LiveOcean/daily/ocean_avg_0001.nc';
 if filenum > 1
     PHYname = fullfile(PHYdir, ['initial_', domain, '_LiveOcean_', datestr(R2R_source_date, 'yyyymmdd'), '.nc']);
     INIname = fullfile(BIOdir, ['initial_', domain, '_LiveOcean_bio_', datestr(R2R_source_date, 'yyyymmdd'), '.nc']);
 end
 R2R_source_file = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_', fstr, '.nc'];
 R2R_source_grid = grd('LiveOcean');

 Tindex = 1;                       % donor time record to read

%  Ratios used to build the biology tracers. Override any field here to
%  depart from the shared defaults, e.g.
%
%     P.Bio_background = 1.0e-1;

 P = spitz_bio_params();

%--------------------------------------------------------------------------
%  Copy the physical file, leaving the original untouched.
%--------------------------------------------------------------------------

if (~exist(PHYname, 'file')),
  error(['D_ADD_BIO - cannot find input file: ', PHYname]);
end

if (exist(INIname, 'file')),
  disp(['Overwriting existing output file: ', INIname]);
end

disp(' ')
disp(['Copying ', PHYname, ' -> ', INIname, ' ...']);

[ok, msg] = copyfile(PHYname, INIname);
if (~ok),
  error(['D_ADD_BIO - failed to copy ', PHYname, ' to ', INIname,       ...
         ': ', msg]);
end

%  Make sure the copy is writable: copyfile preserves the source file
%  permissions, which may be read-only.

fileattrib(INIname, '+w');

%--------------------------------------------------------------------------
%  Define the biology tracer variables in the copy.
%--------------------------------------------------------------------------

S.ncname    = INIname;
S.spherical = nc_read(INIname, 'spherical');

disp(' ')
disp('Defining biology tracer variables ...');
disp('(appending variables to a NetCDF-3 file rewrites it, please wait)');

[~]=c_biology_spitz(S);

%--------------------------------------------------------------------------
%  Build the biology tracers from the donor file.
%--------------------------------------------------------------------------

B = make_spitz_bio(R2R_source_file, R2R_source_grid, g, Tindex, P);

%--------------------------------------------------------------------------
%  Write the biology tracers into the copy.
%--------------------------------------------------------------------------

IniRec = 1;                               % NetCDF time record

bio = spitz_bio_vars();

disp(' ')
disp(['Writing biology tracers to ', INIname, ' ...']);

for vi = 1:length(bio)
  Vname = bio(vi).name;
  [~]=nc_write(INIname, Vname, B.(Vname), IniRec);
end

disp(' ')
disp(['Done. Biology tracers appended to: ', INIname]);

rmpath(this_dir);
rmpath(genpath(roms_matlab));
