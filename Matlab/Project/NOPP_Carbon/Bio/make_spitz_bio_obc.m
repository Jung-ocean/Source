function Bb = make_spitz_bio_obc(Bd, OBC, P, factors)

%
% MAKE_SPITZ_BIO_OBC:  Builds Spitz biology open boundary conditions
%
% Bb = make_spitz_bio_obc(Bd, OBC, P, factors)
%
% Applies the Spitz biology plan to the donor boundary fields returned
% by obc_roms2roms, one grid edge at a time.  The plan itself lives in
% spitz_bio_from_donor.m, which is shared with the initial conditions
% driver so that both are built with identical math.
%
% On Input:
%
%    Bd          Donor boundary structure from obc_roms2roms, holding
%                  '<donor variable>_<edge>' fields (struct array)
%
%    OBC         Boundary edge switches (struct array):
%
%                    OBC.west, OBC.east, OBC.south, OBC.north
%
%    P           Ratios structure (optional; default spitz_bio_params)
%
%    factors     Unit conversion factors keyed by donor variable name
%                  (optional; struct array).  A field that is absent or
%                  empty is treated as 1.
%
% On Output:
%
%    Bb          Structure holding '<Spitz tracer>_<edge>' fields for
%                  every processed edge
%

if (nargin < 4),
  factors = [];
end
if (nargin < 3 || isempty(P)),
  P = spitz_bio_params();
end

%  Donor fields required by spitz_bio_from_donor.

DonorNames = {'NO3', 'NH4', 'SdetritusN', 'SdetritusC',                 ...
              'LdetritusN', 'LdetritusC', 'phytoplankton', 'zooplankton'};

Edges = {'west', 'east', 'south', 'north'};

Bb = struct();

for ie = 1:length(Edges)
  edge = Edges{ie};
  if (~OBC.(edge)), continue, end

  %  Gather this edge's donor fields, applying any unit conversion.

  clear Donor
  for n = 1:length(DonorNames)
    dn    = DonorNames{n};
    field = [dn, '_', edge];

    if (~isfield(Bd, field)),
      error(['MAKE_SPITZ_BIO_OBC - missing donor boundary field: ',     ...
             field]);
    end

    v = Bd.(field);

    if (~isempty(factors) && isfield(factors, dn) &&                    ...
        ~isempty(factors.(dn))),
      v = v*factors.(dn);
    end

    Donor.(dn) = v;
  end

  %  Apply the plan to this edge.

  E = spitz_bio_from_donor(Donor, P, false);

  %  Store as '<tracer>_<edge>'.

  names = fieldnames(E);
  for n = 1:length(names)
    Bb.([names{n}, '_', edge]) = E.(names{n});
  end
end

return
