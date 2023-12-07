function ROMS_plot_temp_function_contour(filename, variname, layer_ind, casename, domain_case, contour)
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

FS = 15;

contour_interval = [6 8 10];

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
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'r');
        h.LineWidth = 1;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200, 'Color', 'r');
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif layer_ind < 0
    
    vari = get_hslice_J(filename,g,variname,layer_ind,'r');
    
    vari_mask = vari.*mask2;
    
    warning off
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'r');
        h.LineWidth = 1;
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200, 'Color', 'r');
    end
    
end