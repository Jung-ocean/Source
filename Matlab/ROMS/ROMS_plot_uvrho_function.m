function ROMS_plot_uvrho_function(filename, variname, variname_u, variname_v, layer_ind, casename, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_current_function(filename, variname, depth_ind, casename, domain_case)
%
%   filename: model output filename (usually netcdf format)
%   variname_u: zonal current variable name in model output file (ex, 'u', 'ubar' ... )
%   variname_v: meridional current variable name in model output file (ex, 'v', 'vbar' ... )
%   layer_ind: layer number you want to plot
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   linewidth: arrow linewidth
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FS = 15;

g = grd(casename);
masku2 = g.mask_u./g.mask_u;
maskv2 = g.mask_v./g.mask_v;

if strcmp(variname, 'v_rho')
    clim = [-10 10];
    contour_interval = [clim(1):5:clim(2)];
    colorbarname = 'cm/s';
    colormapname = 'redblue2';
    
elseif strcmp(variname, 'u_rho')

end

skip = 1;
npts = [0 0 0 0];

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{variname_u})) == 3
        u_2d = nc{variname_u}(layer_ind,:,:);
        v_2d = nc{variname_v}(layer_ind,:,:);
    elseif length(size(nc{variname_u})) == 4
        u_2d = nc{variname_u}(1,layer_ind,:,:);
        v_2d = nc{variname_v}(1,layer_ind,:,:);
    end
    close(nc)
    
    [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    %w = (u_rho+sqrt(-1).*v_rho).*g.mask_rho;
    
    vari = eval(variname)*100; % m/s -> cm/s
    vari_mask = vari.*mask./mask;
    
    map_J(domain_case)
    
    m_pcolor(lon, lat, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(lon, lat, vari_mask, contour_interval, 'k');
        h.LineWidth = 2;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    u_2d = get_hslice_J(filename,g,'u',layer_ind,'u');
    v_2d = get_hslice_J(filename,g,'v',layer_ind,'v');
    
    [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    
    vari = eval(variname)*100;
    vari_mask = vari.*mask./mask;
    
    map_J(domain_case)
    
    warning off
    m_pcolor(lon, lat, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(lon, lat, vari_mask, contour_interval, 'k');
        h.LineWidth = 2;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Label.String = colorbarname; c.Label.FontSize = FS;
    caxis(clim);
    
end