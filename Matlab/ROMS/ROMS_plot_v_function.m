function ROMS_plot_v_function(filename, variname, layer_ind, casename, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_v_function(filename, variname, depth_ind, casename, domain_case, contour)
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
contour_interval = [clim(1):2:clim(2)];
colorbarname = 'cm/s';
colormapname = 'redblue2';

g = grd(casename);
mask2 = g.mask_v./g.mask_v;

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{variname})) == 3
        vari = nc{variname}(layer_ind,:,:);
    elseif length(size(nc{variname})) == 4
        vari = nc{variname}(1,layer_ind,:,:);
    end
    close(nc)
    
    vari_mask = vari.*mask2*100; % m/s -> cm/s
    
    map_J(domain_case)
    
    m_pcolor(g.lon_v, g.lat_v, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_v, g.lat_v, vari_mask, contour_interval, 'k');
        clabel(cs, h);
    end
    
    c = colorbar; c.FontSize = 25;
    c.Title.String = colorbarname; c.Title.FontSize = 25;
    caxis(clim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    vari = get_hslice_J(filename,g,variname,layer_ind,'v');
    
    vari_mask = vari.*mask2;
    
    map_J(domain_case)
    
    warning off
    m_pcolor(g.lon_v, g.lat_v, vari_mask); colormap(colormapname); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_v, g.lat_v, vari_mask, contour_interval, 'k');
        clabel(cs, h);
    end
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
end