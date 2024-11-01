function [han,lon,lat] = roms_plot_river_source_locations(file,g,color)
% han = roms_plot_river_source_locations(file,grd,[color])
% 
% Add symbols to an existing plot to show the locations (u and v faces) 
% of ROMS river point sources.
%
% Symbols '>' and '<' indicate flow through a u-face in the positive,
%         negative direction, respectively
% Symbols '^' and 'v' indicate flow through a v-face in the positive,
%         negative direction, respectively
%
% Inputs:
%
% FILE is a ROMS river forcing file
%      or a structure containing the essential position information 
%      generated using roms_get_source_locations.m
% GRD is a ROMS grid structure
% COLOR (optional) is the symbol color
%
% HANDLE is to the plotted symbols (size number of rivers)
%
% John Wilkin; Sept 28 2014
%              Updated August 2016 to give more detail
%
% See also roms_get_source_locations.m
%
% $Id$

%% Example usage
if 0
  %%
  % plot a checkerboard land/sea mask
  rmask = g.mask_rho;
  [mx,my] = meshgrid(1:size(rmask,2),1:size(rmask,1));
  cmask = rmask*2+mod(mod(mx,2)+mod(my,2),2)+1;
  pcolorjw(g.lon_rho,g.lat_rho,cmask); 
  roms_plot_river_source_locations(file,g)
end

% Input FILE can be a ROMS river forcing file, or a structure containing 
% the position information selected using roms_get_source_locations.m

if isstruct(file)
  xpos = file.xpos;
  ypos = file.epos;
  rdir = file.rdir;
  rsgn = file.rsgn;
else
  xpos = ncread(file,'river_Xposition');
  ypos = ncread(file,'river_Eposition');
  rdir = ncread(file,'river_direction');
  rsgn = sign(mean(ncread(file,'river_transport'),2));
end

% get plot state
nextplotstatewas = get(gca,'nextplot');

% hold whatever is already plotted
set(gca,'nextplot','add')

if nargin < 3
  color = 'r';
end

h = nan(size(xpos));
for r = 1:length(xpos)
  switch rdir(r)
    case 0
      lon(r) = g.lon_u(ypos(r)+1,xpos(r));
      lat(r) = g.lat_u(ypos(r)+1,xpos(r));
      switch rsgn(r)
        case 1
          sym = '>';
        case -1
          sym = '<';
      end
      h(r) = plot(lon(r),lat(r),[color sym]);
    case 1
      switch rsgn(r)
        case 1
          sym = '^';
        case -1
          sym = 'v';
      end
      lon(r) = g.lon_v(ypos(r),xpos(r)+1);
      lat(r) = g.lat_v(ypos(r),xpos(r)+1);
      h(r) = plot(lon(r),lat(r),[color sym]);
    otherwise
      error('invalid river_direction')
  end
end

set(h,'MarkerSize',15)
set(h,'LineWidth',2)
% set(h,'MarkerFaceColor',color)

% label with numbers
plabel = true; 
if plabel
  for r = 1:length(xpos)
    text(lon(r),lat(r),['  ' int2str(r)],'fontsize',20)
  end
end

% restore nextplotstate to what it was
set(gca,'nextplot',nextplotstatewas);

if nargout > 0
  han = h;
end

