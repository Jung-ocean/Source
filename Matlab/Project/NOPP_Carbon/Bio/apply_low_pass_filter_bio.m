%
%  APPLY_LOW_PASS_FILTER_BIO:  Low-pass filters the biology boundary files
%
%  Companion to Boundary/apply_low_pass_filter.m, which does the same for
%  the physical boundary file.  The differences are that the biology
%  tracers live one per file (boundary_<domain>_bio_<tracer>.nc) rather
%  than all in one file, and that the filtered result is floored so that
%  no concentration ends up negative or zero.
%
%  For each tracer this script:
%
%    1) copies boundary_<domain>_bio_<tracer>.nc to
%       boundary_<domain>_bio_<tracer>_<day>d_lpf.nc, leaving the
%       original untouched;
%    2) prepends bry_time = 0 and appends bry_time = end of year, so the
%       series spans the whole run;
%    3) applies a zero-phase Butterworth low-pass filter along time at
%       each vertical level of each processed boundary edge, repeating
%       the first and last filtered values at the two added times;
%    4) floors the result at the donor section minimum (see below).
%
%  Why the floor: biology concentrations must stay strictly positive, as
%  a pool that reaches zero cannot grow.  Interpolating the donor onto
%  the grid edges undershoots near sharp gradients, and the low-pass
%  filter rings below zero around spiky near-zero fields, both of which
%  produce negative or zero values.
%
%  Rather than an arbitrary constant, the floor is taken from the donor
%  itself: for each tracer, edge and time, donor_bio_floor finds the
%  donor line nearest that boundary and takes the smallest strictly
%  positive value over its whole vertical section.  This is a tight,
%  physically meaningful bound that lifts only genuine undershoot.
%
%  Land points are left at exactly zero, so the land mask stays visible
%  in the files.
%

clear; clc

roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

this_dir = fileparts(mfilename('fullpath'));
addpath(this_dir);

%--------------------------------------------------------------------------
%  Settings.
%--------------------------------------------------------------------------

domain = 'Oregon_1km';
g = grd(domain);
N = g.N;

yyyy = 2024;

day  = 5;                      % low-pass cutoff period, days
dstr = num2str(day);

%  Directory holding the biology boundary files.

BIOdir = ['/data/jungjih/Project/NOPP_Carbon/', domain,                 ...
          '/Setups/Bio_LiveOcean'];

%  Donor files supplying the floors, one per day of the year.

DonorPattern = '/data/jungjih/Models/LiveOcean/daily/ocean_avg_%04i.nc';
DonorTindex  = 1;              % time record within each daily file

%  Floor the tracers at the donor section minimum.

APPLY_FLOOR = true;

%  Boundary segments to process.

OBC.west  = true;
OBC.east  = false;
OBC.south = true;
OBC.north = true;

directions = {'north', 'south', 'west', 'east'};
isdirs     = [OBC.north OBC.south OBC.west OBC.east];

bio = spitz_bio_vars();
P   = spitz_bio_params();

%  Design the low-pass filter.

fs = 1;                        % sample/day
fc = 1/day;                    % cycle/day
Wn = fc/(fs/2);
[b,a] = butter(4, Wn, 'low');

%--------------------------------------------------------------------------
%  Wet mask along each boundary edge. Land points stay at zero.
%--------------------------------------------------------------------------

Wet.west  = g.mask_rho(1,:).'   > 0;
Wet.east  = g.mask_rho(end,:).' > 0;
Wet.south = g.mask_rho(:,1)     > 0;
Wet.north = g.mask_rho(:,end)   > 0;

%--------------------------------------------------------------------------
%  Collect the donor floors for every day, once, before filtering. The
%  same floors are then reused for all 17 tracers.
%--------------------------------------------------------------------------

%  Number of time records in the unfiltered files.

probe = fullfile(BIOdir, ['boundary_', domain, '_bio_', bio(1).name, '.nc']);
if (~exist(probe, 'file')),
  error(['APPLY_LOW_PASS_FILTER_BIO - cannot find ', probe]);
end
nt = length(ncread(probe, 'bry_time'));

%  The floors depend only on the donor and the two grids, not on the
%  filter cutoff, so cache them.  Delete the cache file, or set
%  REBUILD_FLOORS, to recompute after changing the donor or the grid.

FloorCache = fullfile(BIOdir, ['donor_bio_floors_', domain, '.mat']);
REBUILD_FLOORS = false;

if (APPLY_FLOOR && ~REBUILD_FLOORS && exist(FloorCache, 'file')),

  disp(['Loading cached donor floors from ', FloorCache]);
  load(FloorCache, 'FloorTS');

elseif (APPLY_FLOOR),

  disp('Mapping boundary edges onto the donor grid ...');

  Dfirst = sprintf(DonorPattern, 1);
  E = donor_edge_index(g, Dfirst, OBC);

  disp(' ')
  disp(['Collecting donor section minima for ', num2str(nt), ' days ...']);

%  FloorTS.(tracer).(edge) is a column of nt floors, one per day.

  FloorTS = struct();
  for bi = 1:length(bio)
    for di = 1:length(directions)
      if (~isdirs(di)), continue, end
      FloorTS.(bio(bi).name).(directions{di}) = zeros([nt 1]);
    end
  end

  for it = 1:nt
    F = donor_bio_floor(sprintf(DonorPattern, it), DonorTindex, E, OBC, P);
    for bi = 1:length(bio)
      vname = bio(bi).name;
      for di = 1:length(directions)
        if (~isdirs(di)), continue, end
        edge = directions{di};
        FloorTS.(vname).(edge)(it) = F.(vname).(edge);
      end
    end
    if (mod(it,25) == 0 || it == nt),
      disp(['  ', num2str(it), ' / ', num2str(nt)]);
    end
  end

  save(FloorCache, 'FloorTS');
  disp(['Cached donor floors to ', FloorCache]);

end

%--------------------------------------------------------------------------
%  Filter every biology tracer file.
%--------------------------------------------------------------------------

for bi = 1:length(bio)

  vname = bio(bi).name;

  filename_org = fullfile(BIOdir,                                       ...
                          ['boundary_', domain, '_bio_', vname, '.nc']);
  filename     = fullfile(BIOdir,                                       ...
                          ['boundary_', domain, '_bio_', vname, '_',    ...
                           dstr, 'd_lpf.nc']);

  if (~exist(filename_org, 'file')),
    disp(['SKIP - cannot find ', filename_org]);
    continue
  end

  copyfile(filename_org, filename);
  fileattrib(filename, '+w');

%  Extend the time axis to the start and the end of the year.

  bry_time = ncread(filename, 'bry_time');

  if bry_time(1) ~= 0
      bry_time = [0; bry_time];
  end
  if bry_time(end) ~= yeardays(yyyy)*60*60*24
      bry_time = [bry_time; yeardays(yyyy)*60*60*24];
  end
  ncwrite(filename, 'bry_time', bry_time);

  nt2 = length(bry_time);

%  Filter each processed boundary edge.

  for di = 1:length(directions)

    if (~isdirs(di)), continue, end

    direction = directions{di};
    vari_str  = [vname, '_', direction];

%  Writing the extended bry_time above already grew the record dimension
%  to nt2, so the variable now reads back with nt2 records, the last two
%  of which are unwritten.  Keep only the nt real ones.

    vari    = double(ncread(filename, vari_str));
    vari    = vari(:,:,1:nt);
    vari_nc = zeros([size(vari,1) N nt2]);

    wet = Wet.(direction);
    fl  = [];

%  Floor BEFORE filtering.  The interpolated field carries negative
%  undershoot, and filtfilt would smear those values across the whole
%  filter window, dragging down neighbouring records that were fine.
%  Flooring first keeps the bad values out of the window altogether.

    if (APPLY_FLOOR),
      fl = FloorTS.(vname).(direction);
      [vari, nbefore] = apply_edge_floor(vari, fl, wet);
    end

    for i = 1:N
      vari_tmp = squeeze(vari(:,i,1:nt));
      vari_lp  = [filtfilt(b,a,vari_tmp')]';
      vari_lp  = [vari_lp(:,1) vari_lp vari_lp(:,end)];
      vari_nc(:,i,:) = vari_lp;
    end

%  Floor AFTER filtering.  Flooring the input is not enough on its own:
%  a low-pass filter still rings below the floor around sharp features,
%  so this pass is what guarantees a strictly positive result.  The two
%  added times repeat the first and last day's floor, matching the
%  repeated data values.

    if (APPLY_FLOOR),
      [vari_nc, nafter] = apply_edge_floor(vari_nc, [fl(1); fl; fl(end)], wet);

      npts = sum(wet)*N*nt;
      disp(['    floored ', num2str(nbefore), ' wet values before (',   ...
            num2str(100*nbefore/npts, '%.2f'), '%) and ',               ...
            num2str(nafter), ' after (',                                ...
            num2str(100*nafter/(sum(wet)*N*nt2), '%.2f'), '%), ',       ...
            'donor floor ', num2str(min(fl), '%.4g'), ' to ',           ...
            num2str(max(fl), '%.4g')]);
    end

    ncwrite(filename, vari_str, vari_nc);

    disp(['Applying ', dstr, ' day lowpass filter to ', vari_str])

  end % di

end % bi

disp(' ')
disp(['Done. Filtered files: boundary_', domain, '_bio_<tracer>_',      ...
      dstr, 'd_lpf.nc in ', BIOdir]);

rmpath(this_dir);
rmpath(genpath(roms_matlab));
