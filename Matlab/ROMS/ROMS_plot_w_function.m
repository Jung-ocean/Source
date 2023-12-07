function ROMS_plot_w_function(filename, variname, layer_ind, casename, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_temp_function(filename, variname, depth_ind, casename, domain_case, contour)
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

clim = [-1e-4 1e-4];
colorbarname = 'W-velocity (m/s)';
colormapname = 'parula';

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

if layer_ind > 0
    nc = netcdf(filename);
    
    if layer_ind == 99
        
        if length(size(nc{variname})) == 3
            vari = squeeze(mean(nc{variname}(:,:,:)));
        elseif length(size(nc{variname})) == 4
            vari = squeeze(mean(nc{variname}(1,:,:,:)));
        end
        
    else
        
        if length(size(nc{variname})) == 3
            vari = nc{variname}(layer_ind,:,:);
        elseif length(size(nc{variname})) == 4
            vari = nc{variname}(1,layer_ind,:,:);
        end
        
    end
    
    close(nc)
    
    vari_mask = vari.*mask2;
    
    map_J(domain_case)
    
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    %     if strcmp(contour, 'contour on')
    %         [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
    %         clabel(cs, h);
    %     end
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    vari = get_hslice_J(filename,g,variname,layer_ind,'r');
    
    vari_mask = vari.*mask2;
    
    map_J(domain_case)
    
    warning off
    m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap(colormapname); shading flat;
    
    %     if strcmp(contour, 'contour on')
    %         [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
    %         clabel(cs, h);
    %     end
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
end