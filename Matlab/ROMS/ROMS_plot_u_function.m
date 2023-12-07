function ROMS_plot_u_function(filename, variname_u, variname_v, layer_ind, casename, domain_case, rotind, theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_u_function(filename, variname, depth_ind, casename, domain_case, contour)
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
clim = [-50 50];
contour_interval = [clim(1):10:clim(2)];
colorbarname = 'cm/s';
colormapname = 'redblue2';

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{variname_u})) == 3
        u = nc{variname_u}(layer_ind,:,:);
        v = nc{variname_v}(layer_ind,:,:);
    elseif length(size(nc{variname_u})) == 4
        u = nc{variname_u}(1,layer_ind,:,:);
        v = nc{variname_v}(1,layer_ind,:,:);
    end
    close(nc)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    u = get_hslice_J(filename,g,variname_u,layer_ind,'u');
    v = get_hslice_J(filename,g,variname_v,layer_ind,'v');
end

skip = 1; npts = [0 0 0 0];
[u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u.*g.mask_u,v.*g.mask_v,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

if rotind == 1
    u_rho = cosd(theta)*u_rho + -sind(theta)*v_rho;
    v_rho = sind(theta)*u_rho + cosd(theta)*v_rho;
end
    
vari_mask = u_rho.*mask2.*100; % m/s -> cm/s

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