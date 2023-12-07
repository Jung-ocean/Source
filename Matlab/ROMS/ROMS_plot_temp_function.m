function ROMS_plot_temp_function(filename, variname, layer_ind, casename, domain_case, contour)
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

clim = [0 30];
if layer_ind == 1
    %    contour_interval = [10 10];
    contour_interval = [clim(1):2:clim(2)];
elseif strcmp(casename, 'NP') || strcmp(casename, 'NWP')
    contour_interval = [clim(1):4:clim(2)];
else
    %      contour_interval = [clim(1):2:clim(2)];
    contour_interval = [0:2:30];
end

colorbarname = '^oC';
colormapname = 'parula';
FS = 15;

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

if layer_ind > 0
    
    nc = netcdf(filename);
    if length(size(nc{variname})) == 3
        vari = nc{variname}(layer_ind,:,:);
    elseif length(size(nc{variname})) == 4
        vari = nc{variname}(1,layer_ind,:,:);
    end
    close(nc)
    
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
    
    vari = get_hslice_J(filename,g,variname,layer_ind,'r');
    
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