function ROMS_plot_temp_comp_function(filename, variname, layer_ind, casename, domain_case, contour)
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
contour_interval = [clim(1):2:clim(2)];
colorbarname = '^oC';

FS = 15;

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

    nc = netcdf(filename);
    if length(size(nc{variname})) == 3
        vari_bot = nc{variname}(1,:,:);
    elseif length(size(nc{variname})) == 4
        vari_bot = nc{variname}(1,1,:,:);
    end
    close(nc)
    vari_bot_mask = vari_bot.*mask2;

    vari = get_hslice_J(filename,g,variname,layer_ind,'r');
    vari_mask = vari.*mask2;
    
    vari_comp = vari_mask;
    index_nan = isnan(vari_comp) == 1;
    vari_comp(index_nan) = vari_bot_mask(index_nan);
    
    map_J(domain_case)
    
    warning off
    m_pcolor(g.lon_rho, g.lat_rho, vari_comp); colormap('parula'); shading flat;
    
    if strcmp(contour, 'contour on')
        [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_comp, contour_interval, 'k');
        clabel(cs, h, 'FontSize', FS, 'FontWeight', 'bold', 'LabelSpacing', 200);
    end
    
    c = colorbar; c.FontSize = FS;
    c.Title.String = colorbarname; c.Title.FontSize = FS;
    caxis(clim);
    
end