function h = roms_plot_mesh(g,varargin)
% $Id: roms_plot_mesh.m 439 2016-02-18 20:33:59Z wilkin $
% han = roms_plot_mesh(grd,[decimation_factor,color,cgridposition])
%
% Plot a mesh showing a ROMS grid over an existing plot
%
% Options can be in any order, or absent
%   decimation factor - integer > 0 controls density of mesh (default 10)
%   color - any 1-character color strong supported by plot
%         - a real number < 1 is interpreted as grey scale
%   cgrid - a string 'rho', 'psi', 'edge' (or 'boundary')
%
% John Wilkin

% get plot state
nextplotstatewas = get(gca,'nextplot');

% hold whatever is already plotted
set(gca,'nextplot','add')

n = 5;
color = 0.7*[1 1 1];
cgrid = 'psi';
for i=1:length(varargin)
  opt = varargin{i};
  if isnumeric(opt)
    if length(opt)>1
      color = opt;
    else
      if opt < 1
        color = opt*[1 1 1];
      else
        n = opt;
      end
    end
  end
  if ischar(opt)
    if length(opt)==1
      color = opt;
    else
      cgrid = opt(1:3);
    end
  end
end

m = ones(size(g.lon_psi));
% m = av2(av2(g.mask_rho)')'; m(m<0.5) = NaN; m(~isnan(m)) = 1;

switch cgrid(1)
  case 'r'
    han1=plot(g.lon_rho(1:n:end,1:n:end),g.lat_rho(1:n:end,1:n:end),'w-');
    han2=plot(g.lon_rho(1:n:end,1:n:end)',g.lat_rho(1:n:end,1:n:end)','w-');
    han = [han1; han2];
  case 'p'
    m = m(1:n:end,1:n:end);
    han1=plot(m.*g.lon_psi(1:n:end,1:n:end),m.*g.lat_psi(1:n:end,1:n:end),'w-');
    han2=plot((m.*g.lon_psi(1:n:end,1:n:end))',(m.*g.lat_psi(1:n:end,1:n:end))','w-');
    han = [han1; han2];
  otherwise
    % we presume edge or boundary 
    han1=plot(g.lon_psi(1:end,1),g.lat_psi(1:end,1),'w-');
    han2=plot(g.lon_psi(1:end,end),g.lat_psi(1:end,end),'w-');
    han3=plot(g.lon_psi(1,1:end),g.lat_psi(1,1:end),'w-');
    han4=plot(g.lon_psi(end,1:end),g.lat_psi(end,1:end),'w-');
    han = [han1; han2; han3; han4];
end

set(han,'linew',0.5,'color',color);

if nargout>0
  h = han;
end

% restore nextplotstate to what it was
set(gca,'nextplot',nextplotstatewas);
