function Floor = donor_bio_floor(Dname, Tindex, E, OBC, P)

%
% DONOR_BIO_FLOOR:  Per-edge floors for the Spitz tracers, from the donor
%
% Floor = donor_bio_floor(Dname, Tindex, E, OBC, P)
%
% Biology concentrations must stay strictly positive: a zero pool cannot
% grow, and interpolation or filtering can undershoot into negative
% values.  This function derives a physically defensible floor from the
% donor itself rather than from an arbitrary constant.
%
% For each processed boundary edge it takes the donor line nearest that
% boundary (built by donor_edge_index.m), reads the donor biology fields
% over the whole vertical section of that line at the requested time, and
% takes the smallest strictly positive value.  Those donor minima are then
% pushed through spitz_bio_from_donor, so the 17 tracer floors are built
% with exactly the same plan as the tracers themselves.  That mapping is
% exact: every tracer is a non-negative multiple of a donor pool, and the
% one non-linear case (Bacteria) uses max, which is monotonic, so the
% minimum of a tracer is the tracer of the minimum.
%
% On Input:
%
%    Dname       Donor NetCDF file name
%    Tindex      Time record to read from the donor (scalar)
%    E           Edge to donor index mapping, from donor_edge_index
%    OBC         Boundary edge switches (struct array)
%    P           Ratios structure (optional; default spitz_bio_params)
%
% On Output:
%
%    Floor       Structure Floor.(tracer).(edge) = scalar floor value
%

if (nargin < 5 || isempty(P)),
  P = spitz_bio_params();
end

DonorNames = {'NO3', 'NH4', 'SdetritusN', 'SdetritusC',                 ...
              'LdetritusN', 'LdetritusC', 'phytoplankton', 'zooplankton'};

Edges = {'west', 'east', 'south', 'north'};

Floor = struct();

%  Number of donor vertical levels. Inquired once here rather than per
%  variable and edge, which would reopen the file 24 times per day.

dinfo = ncinfo(Dname, DonorNames{1});
ns    = dinfo.Size(3);

for ie = 1:length(Edges)

  edge = Edges{ie};
  if (~OBC.(edge)), continue, end
  if (~isfield(E, edge)), continue, end

  ix = E.(edge).ix;
  iy = E.(edge).ie;

%  Read the donor bounding box containing this line. Each edge maps to a
%  single donor row or column, so this is a small read.

  x0 = min(ix);   nx = max(ix)-x0+1;
  y0 = min(iy);   ny = max(iy)-y0+1;

%  Linear indices of the section points inside the bounding box.

  sub = sub2ind([nx ny], ix-x0+1, iy-y0+1);

  Dmin = struct();

  for n = 1:length(DonorNames)

    vname = DonorNames{n};

%  Donor variables are (ocean_time, s_rho, eta_rho, xi_rho) in the file,
%  which Matlab presents as (xi_rho, eta_rho, s_rho, ocean_time).

    v = ncread(Dname, vname, [x0 y0 1 Tindex], [nx ny ns 1]);
    v = double(v);

%  Collect the section over all vertical levels.

    v = reshape(v, [nx*ny ns]);
    s = v(sub,:);
    s = s(:);

%  Smallest strictly positive value, ignoring land fill values.

    s = s(isfinite(s) & s > 0 & s < 1.0e30);

    if (isempty(s)),
      error(['DONOR_BIO_FLOOR - no positive donor values for ', vname,  ...
             ' on the ', edge, ' edge at record ', num2str(Tindex)]);
    end

    Dmin.(vname) = min(s);

  end

%  Map the donor minima through the same plan used to build the tracers.

  B = spitz_bio_from_donor(Dmin, P, false);

  names = fieldnames(B);
  for n = 1:length(names)
    Floor.(names{n}).(edge) = B.(names{n});
  end

end

return
