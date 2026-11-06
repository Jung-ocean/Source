function E = donor_edge_index(g, Dname, OBC)

%
% DONOR_EDGE_INDEX:  Maps each receiver boundary edge onto the donor grid
%
% E = donor_edge_index(g, Dname, OBC)
%
% For every processed boundary edge of the receiver grid, finds the
% nearest donor RHO-point to each wet edge point.  Together these points
% form the donor line lying closest to that boundary, which is used by
% donor_bio_floor.m to take section minima.
%
% The mapping depends only on the two grids, so build it once and reuse
% it for every time record.
%
% On Input:
%
%    g           Receiver grid structure (from grd/get_roms_grid), with
%                  lon_rho, lat_rho and mask_rho
%    Dname       Donor NetCDF file name, carrying lon_rho and lat_rho
%    OBC         Boundary edge switches (struct array):
%                  OBC.west, OBC.east, OBC.south, OBC.north
%
% On Output:
%
%    E           Structure, one field per processed edge:
%
%                  E.(edge).ix    donor xi  index, per wet edge point
%                  E.(edge).ie    donor eta index, per wet edge point
%                  E.(edge).wet   logical mask of wet points along the
%                                   receiver edge
%

DLon = ncread(Dname, 'lon_rho');           % (xi_d, eta_d)
DLat = ncread(Dname, 'lat_rho');

RLon = g.lon_rho;                          % (xi_r, eta_r)
RLat = g.lat_rho;
RMask = g.mask_rho;

dl = DLon(:);
da = DLat(:);
dsz = size(DLon);

Edges = {'west', 'east', 'south', 'north'};

E = struct();

for ie = 1:length(Edges)

  edge = Edges{ie};
  if (~OBC.(edge)), continue, end

%  Coordinates along this receiver edge.  West and east run along eta,
%  south and north run along xi.

  switch edge
    case 'west'
      lo = RLon(1,:).';    la = RLat(1,:).';    mk = RMask(1,:).';
    case 'east'
      lo = RLon(end,:).';  la = RLat(end,:).';  mk = RMask(end,:).';
    case 'south'
      lo = RLon(:,1);      la = RLat(:,1);      mk = RMask(:,1);
    case 'north'
      lo = RLon(:,end);    la = RLat(:,end);    mk = RMask(:,end);
  end

  wet = mk > 0;

  lo = lo(wet);
  la = la(wet);

  npts = length(lo);
  ix = zeros([npts 1]);
  iy = zeros([npts 1]);

  for k = 1:npts
    [~, im] = min((dl-lo(k)).^2 + (da-la(k)).^2);
    [ix(k), iy(k)] = ind2sub(dsz, im);
  end

  E.(edge).ix  = ix;
  E.(edge).ie  = iy;
  E.(edge).wet = wet;

  disp(['  ', edge, ' edge: ', num2str(npts), ' wet points -> donor ',  ...
        'xi ', num2str(min(ix)), '-', num2str(max(ix)),                 ...
        ', eta ', num2str(min(iy)), '-', num2str(max(iy))]);

end

return
