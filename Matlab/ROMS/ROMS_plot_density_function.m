function ROMS_plot_density_function(filename, layer_ind, casename, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_density_function(filename, variname, depth, casename, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   depth: depth(m) you want to plot
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clim = [15 28];
contour_interval = [clim(1):2:clim(2)];
colorbarname = '\sigma_t';
colormapname = 'jet';
FS = 15;

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{'temp'})) == 3
        temp = nc{'temp'}(layer_ind,:,:);
        salt = nc{'salt'}(layer_ind,:,:);
                
        %vari = nc{variname}(layer_ind,:,:);
    elseif length(size(nc{'temp'})) == 4
        temp = nc{'temp'}(1,layer_ind,:,:);
        salt = nc{'salt'}(1,layer_ind,:,:);
                
        %vari = nc{variname}(1,layer_ind,:,:);
    end
    zeta = nc{'zeta'}(:);
    close(nc)

    salt = salt.*g.mask_rho; salt(salt < 0) = 0;
    temp = temp.*g.mask_rho;
    
    depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    pres = sw_pres(g.mask_rho.*squeeze(depth(layer_ind,:,:)), g.lat_rho);
    pden = sw_pden_ROMS(salt, temp, pres, 0);
    
    vari = pden - 1000;
    vari_mask = vari.*mask2;
    
    map_J(domain_case)
    
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
        h.LineWidth = 1;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    temp = get_hslice_J(filename, g, 'temp', layer_ind, 'r');
    salt = get_hslice_J(filename, g, 'salt', layer_ind, 'r');
    
    pres = sw_pres(layer_ind*ones(size(g.lat_rho)), g.lat_rho);
    pden = sw_pden_ROMS(salt, temp, pres, 0);
    
    vari = pden - 1000;    
    vari_mask = vari.*mask2;
    
    map_J(domain_case)
    
    warning off
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
        h.LineWidth = 1;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
end