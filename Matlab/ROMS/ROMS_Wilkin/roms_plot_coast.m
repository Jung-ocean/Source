function h = roms_plot_coast(g,c)
% $Id:$
% han = roms_plot_coast(grd,color)
%
% Plot coastline over an existing plot
% assuming lon_coast and lat_coast are in the GRD structure or file
% Will work for any structure with lon_coast,lat_coast, e.g.
%       roms_plot_coast(coastline_ec,color)

% get plot state
nextplotstatewas = get(gca,'nextplot');

% hold whatever is already plotted
set(gca,'nextplot','add')

if nargin < 2
  c = 0.4*[1 1 1];
end

if ~isstruct(g)
  g = roms_get_grid(g);
end

han = plot(g.lon_coast,g.lat_coast,'-');
set(han,'linew',0.5,'color',c);

if nargout>0
  h = han;
end

% restore nextplotstate to what it was
set(gca,'nextplot',nextplotstatewas);
