function ROMS_plot_vbar_function(filename, variname_u, variname_v, casename, domain_case, rotind, theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_ubar_function(filename, variname, depth_ind, casename, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   variname: temperature variable name in model output file (ex, 'temp', 'temperautre' ... )
%   layer_ind: layer number you want to plot
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clim = [-20 20];
contour_interval = [clim(1):10:clim(2)];
colorbarname = 'cm/s';
colormapname = 'redblue2';

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

nc = netcdf(filename);
if length(size(nc{variname_u})) == 2
    ubar = nc{variname_u}(:);
    vbar = nc{variname_v}(:);
elseif length(size(nc{variname_u})) == 3
    ubar = nc{variname_u}(1,:);
    vbar = nc{variname_v}(1,:);
end
close(nc)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

skip = 1; npts = [0 0 0 0];
[ubar_rho,vbar_rho,lon,lat,mask] = uv_vec2rho(ubar.*g.mask_u,vbar.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

if rotind == 1
    ubar_rho = cosd(theta)*ubar_rho + -sind(theta)*vbar_rho;
    vbar_rho = sind(theta)*ubar_rho + cosd(theta)*vbar_rho;
end
    
vari_mask = vbar_rho.*mask2.*100; % m/s -> cm/s

map_J(domain_case)

warning off
m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;

% if strcmp(contour, 'contour on')
%     [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
%     clabel(cs, h);
% end

c = colorbar; c.FontSize = 15;
c.Title.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);