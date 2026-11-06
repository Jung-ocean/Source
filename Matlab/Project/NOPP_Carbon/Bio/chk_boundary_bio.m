%
%  CHK_BOUNDARY_BIO:  Compares donor and boundary values for the biology
%                     tracers
%
%  Companion to Boundary/chk_boundary.m, which does the same for the
%  physical fields.  The differences are that the biology tracers live
%  one per file, that the donor variable feeding each tracer has a
%  different name, and that most tracers are a scaled fraction of their
%  donor pool rather than a copy of it.
%
%  For a fair comparison the donor section is multiplied by the same
%  factor the tracer was built with, so the two panels should look the
%  same.  A visible difference means the interpolation, the filtering or
%  the flooring changed something, not that the plan was applied.
%
%  The factors are taken from spitz_bio_params, so they follow whatever
%  is set there.  For the current settings:
%
%     Phytoplankton  = 0.50 x donor phytoplankton
%     Diatoms        = 0.50 x donor phytoplankton
%     Chlorophyll    = 0.30 x donor phytoplankton
%     ChlD           = 1.00 x donor phytoplankton
%     Silica         = 1.00 x donor NO3
%     LDetS          = 1.00 x donor LdetritusN
%
%  DON and DOC have no donor counterpart at all, and Bacteria is floored,
%  so those are reported but only the boundary panel is meaningful.
%
%  A numeric summary of both sections is printed to the command window
%  alongside the figures.
%

clear; clc; close all

roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);

%--------------------------------------------------------------------------
%  Settings.
%--------------------------------------------------------------------------

domain = 'Oregon_1km';
yyyy   = 2024;

%  Day of year to look at. The donor file for that day is compared with
%  the matching record of the boundary file.

time_rec = 3;
fstr     = num2str(time_rec, '%04i');

%  Boundary edge to section.

direction = 'west';               % 'west', 'south' or 'north'

%  Which boundary file to compare against the donor.  The unfiltered
%  files show what the interpolation produced, before the low-pass
%  filter and the flooring changed anything, so they are the right thing
%  to look at when checking the interpolation itself.

USE_LPF = false;                  % false: unfiltered, true: low-pass filtered
day     = 5;                      % filter cutoff used, for the file name

%  Show the donor, the unfiltered boundary and the filtered boundary in
%  three panels instead of two.  Handy for seeing what the filter did;
%  ignores USE_LPF.

SHOW_BOTH = true;

%  Directories.

BIOdir = ['/data/jungjih/Project/NOPP_Carbon/', domain,                 ...
          '/Setups/Bio_LiveOcean'];

source = ['/data/jungjih/Models/LiveOcean/daily/ocean_avg_', fstr, '.nc'];

gs = grd('LiveOcean');            % donor grid
g  = grd(domain);                 % receiver grid

%  Tracers to check. Set to {bio.name} for all 17.

varis = {'NO3', 'NH4', 'Phytoplankton', 'Diatoms', 'Chlorophyll',       ...
         'ChlD', 'DetN', 'DetC', 'LDetN', 'LDetC', 'Silica'};

%  Save a PNG per tracer.

SAVE_PNG = true;

%--------------------------------------------------------------------------
%  Donor pool and scale factor behind each tracer, from spitz_bio_params.
%  Column 1 is the tracer, column 2 the donor variable it comes from, and
%  column 3 the factor applied to the donor.
%--------------------------------------------------------------------------

P = spitz_bio_params();

Map = {'NO3',              'NO3',           1;                          ...
       'NH4',              'NH4',           1;                          ...
       'DetN',             'SdetritusN',    1;                          ...
       'DetC',             'SdetritusC',    1;                          ...
       'LDetN',            'LdetritusN',    1;                          ...
       'LDetC',            'LdetritusC',    1;                          ...
       'Silica',           'NO3',           P.SiN_ratio;                ...
       'LDetS',            'LdetritusN',    P.SiN_ratio;                ...
       'Phytoplankton',    'phytoplankton', P.phyto_diatom_split;       ...
       'Diatoms',          'phytoplankton', 1-P.phyto_diatom_split;     ...
       'Microzooplankton', 'zooplankton',   P.zoo_micro_split;          ...
       'Mesozooplankton',  'zooplankton',   1-P.zoo_micro_split;        ...
       'Chlorophyll',      'phytoplankton',                             ...
                            P.ChlN_phyto*P.phyto_diatom_split;          ...
       'ChlD',             'phytoplankton',                             ...
                            P.ChlN_diatom*(1-P.phyto_diatom_split);     ...
       'Bacteria',         'phytoplankton',                             ...
                            P.Bacteria_fraction*P.phyto_diatom_split;   ...
       'DON',              '',              NaN;                        ...
       'DOC',              '',              NaN};

bio = spitz_bio_vars();

%--------------------------------------------------------------------------
%  Locate the donor section nearest this boundary edge, once.
%--------------------------------------------------------------------------

lon_source = gs.lon_rho;   lat_source = gs.lat_rho;
lon_bndy   = g.lon_rho;    lat_bndy   = g.lat_rho;

switch direction
  case 'south'
    lat  = min(lat_bndy(:));
    lon1 = min(lon_bndy(:));
    lon2 = max(lon_bndy(:));

    latdist = abs(gs.lat_rho(1,:) - lat);
    latind  = find(latdist == min(latdist));
    lonind  = find(gs.lon_rho(:,1) > lon1 & gs.lon_rho(:,1) < lon2);

    start_s = [lonind(1) latind 1 1];
    count_s = [length(lonind) 1 Inf 1];

    z_source    = squeeze(gs.z_r(lonind, latind, :));
    xdata_source = repmat(lon_source(lonind, latind), [1 gs.N]);

    z_bndy      = squeeze(g.z_r(:, 1, :));
    xdata_bndy  = repmat(lon_bndy(:, 1), [1 g.N]);

    xlabel_str = 'Longitude';

  case 'north'
    lat  = max(lat_bndy(:));
    lon1 = min(lon_bndy(:));
    lon2 = max(lon_bndy(:));

    latdist = abs(gs.lat_rho(1,:) - lat);
    latind  = find(latdist == min(latdist));
    lonind  = find(gs.lon_rho(:,end) > lon1 & gs.lon_rho(:,end) < lon2);

    start_s = [lonind(1) latind 1 1];
    count_s = [length(lonind) 1 Inf 1];

    z_source    = squeeze(gs.z_r(lonind, latind, :));
    xdata_source = repmat(lon_source(lonind, latind), [1 gs.N]);

    z_bndy      = squeeze(g.z_r(:, end, :));
    xdata_bndy  = repmat(lon_bndy(:, end), [1 g.N]);

    xlabel_str = 'Longitude';

  case 'west'
    lon  = min(lon_bndy(:));
    lat1 = min(lat_bndy(:));
    lat2 = max(lat_bndy(:));

    londist = abs(gs.lon_rho(:,1) - lon);
    lonind  = find(londist == min(londist));
    latind  = find(gs.lat_rho(1,:) > lat1 & gs.lat_rho(1,:) < lat2);

    start_s = [lonind latind(1) 1 1];
    count_s = [1 length(latind) Inf 1];

    z_source    = squeeze(gs.z_r(lonind, latind, :));
    xdata_source = repmat(lat_source(lonind, latind)', [1 gs.N]);

    z_bndy      = squeeze(g.z_r(1, :, :));
    xdata_bndy  = repmat(lat_bndy(1, :)', [1 g.N]);

    xlabel_str = 'Latitude';
end

%--------------------------------------------------------------------------
%  Boundary record matching this day.  The filtered files carry two extra
%  records (bry_time = 0 at the start and the end of the year), so the
%  record is found by matching bry_time rather than assuming an index.
%--------------------------------------------------------------------------

refdate  = datenum(yyyy,1,1);
StrDay   = datenum(yyyy,1,1,12,0,0) + time_rec - 1;
want_sec = (StrDay - refdate)*86400;

disp(' ')
disp(['Comparing donor and boundary on ', datestr(StrDay),              ...
      '  (', direction, ' edge)']);
disp(['  donor file : ', source]);

%--------------------------------------------------------------------------
%  Compare each tracer.
%--------------------------------------------------------------------------

if (SHOW_BOTH),
  npanel = 3;
else
  npanel = 2;
end

figure;
set(gcf, 'Position', [1 200 400*npanel 500])
t = tiledlayout(1,npanel);
t.Padding = 'compact';
t.TileSpacing = 'compact';

disp(' ')
disp('  tracer            donor x factor                boundary')
disp(['  ', repmat('-',[1 68])]);

for vi = 1:length(varis)

  vari = varis{vi};

  mi = find(strcmp(Map(:,1), vari), 1);
  if (isempty(mi)),
    disp(['  ', vari, ': not a known Spitz tracer, skipping']);
    continue
  end
  dvar   = Map{mi,2};
  factor = Map{mi,3};

  bi   = find(strcmp({bio.name}, vari), 1);
  unit = bio(bi).units;

%  Boundary files to show.

  rawname = fullfile(BIOdir, ['boundary_', domain, '_bio_', vari, '.nc']);
  lpfname = fullfile(BIOdir, ['boundary_', domain, '_bio_', vari, '_',  ...
                              num2str(day), 'd_lpf.nc']);

  if (SHOW_BOTH),
    blist = {rawname, 'unfiltered'; lpfname, [num2str(day), 'd lpf']};
  elseif (USE_LPF),
    blist = {lpfname, [num2str(day), 'd lpf']};
  else
    blist = {rawname, 'unfiltered'};
  end

%  Read each of them at the record matching this day.

  bdata = cell([size(blist,1) 1]);
  missing = false;

  for k = 1:size(blist,1)
    bname = blist{k,1};

    if (~exist(bname, 'file')),
      disp(['  ', vari, ': cannot find ', bname, ', skipping']);
      missing = true;
      break
    end

    bry_time = ncread(bname, 'bry_time');
    brec = find(abs(bry_time - want_sec) < 1, 1);
    if (isempty(brec)),
      disp(['  ', vari, ': no record for this day in ', bname,          ...
            ', skipping']);
      missing = true;
      break
    end

    v = ncread(bname, [vari, '_', direction], [1 1 brec], [Inf Inf 1]);
    v = double(squeeze(v));
    v(v == 0) = NaN;                           % land
    bdata{k} = v;
  end

  if (missing), continue, end

  vari_bndy = bdata{1};

%  Donor section, scaled by the factor this tracer was built with.

  if (~isempty(dvar)),
    vari_source = ncread(source, dvar, start_s, count_s);
    vari_source = double(squeeze(vari_source));
    vari_source(vari_source > 1.0e30) = NaN;   % land fill
    vari_source = factor*vari_source;
    have_source = true;
  else
    vari_source = nan(size(xdata_source));
    have_source = false;
  end

%  Numeric comparison.

  s = vari_source(isfinite(vari_source));

  for k = 1:size(blist,1)
    b = bdata{k}(isfinite(bdata{k}));
    if (k == 1),
      tag = vari;
    else
      tag = '';
    end
    if (have_source && k == 1),
      fprintf('  %-17s %8.4g %8.4g %8.4g | %-11s %8.4g %8.4g %8.4g\n',  ...
              tag, min(s), mean(s), max(s), blist{k,2},                 ...
              min(b), mean(b), max(b));
    elseif (have_source),
      fprintf('  %-17s %26s | %-11s %8.4g %8.4g %8.4g\n',               ...
              tag, '', blist{k,2}, min(b), mean(b), max(b));
    else
      fprintf('  %-17s %26s | %-11s %8.4g %8.4g %8.4g\n',               ...
              tag, '(no donor counterpart)', blist{k,2},                ...
              min(b), mean(b), max(b));
    end
  end

%  Common colour limits from every panel, robust to outliers.

  both = s;
  for k = 1:size(blist,1)
    bk = bdata{k};
    both = [both; bk(isfinite(bk))];                                  %#ok<AGROW>
  end
  if (isempty(both)),
    climit = [0 1];
  else
    climit = [prctile(both,1) prctile(both,99)];
    if (climit(2) <= climit(1)), climit = [min(both) max(both)+eps]; end
  end

%  Donor.

  nexttile(1);
  if (have_source),
    p1 = pcolor(xdata_source, z_source, vari_source); shading flat
    ttl = ['Donor ', dvar, ' x ', num2str(factor)];
  else
    p1 = pcolor(xdata_source, z_source, vari_source); shading flat
    ttl = ['Donor: none for ', vari];
  end
  colormap jet(12);
  caxis(climit)
  xlabel(xlabel_str)
  ylabel('Depth (m)')
  title(ttl, 'FontSize', 13, 'Interpreter', 'none');

%  Boundary panels.

  ph = cell([size(blist,1) 1]);

  for k = 1:size(blist,1)
    nexttile(1+k);
    ph{k} = pcolor(xdata_bndy, z_bndy, bdata{k}); shading flat
    colormap jet(12);
    caxis(climit)
    xlabel(xlabel_str)
    yticklabels('')
    if (k == size(blist,1)),
      c = colorbar;
      c.Title.String = bio_unit_label(unit);
      c.Title.Interpreter = 'tex';    % renders the m^{-3} exponent
    end
    title(['Boundary ', vari, ' (', blist{k,2}, ')'],                   ...
          'FontSize', 13, 'Interpreter', 'none');
  end

  if (SAVE_PNG),
    if (SHOW_BOTH),
      suffix = '_both';
    elseif (USE_LPF),
      suffix = ['_', num2str(day), 'dlpf'];
    else
      suffix = '_raw';
    end
    print(['chk_bndy_bio_', vari, '_', direction, '_', fstr, suffix],   ...
          '-dpng')
  end

  delete(p1);
  for k = 1:size(blist,1), delete(ph{k}); end

end

disp(' ')
disp('Donor columns are min / mean / max of the scaled donor section,');
disp('boundary columns the same for the interpolated boundary section.');
disp('They will not match exactly: the boundary is interpolated onto a');
disp('finer grid, then low-pass filtered and floored.');

rmpath(this_dir);
rmpath(genpath(roms_matlab));
