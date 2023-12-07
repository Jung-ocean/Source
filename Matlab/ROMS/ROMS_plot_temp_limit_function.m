function ROMS_plot_temp_limit_function(filename, variname, layer_ind, casename, domain_case, contour, limit)
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

temp_limit = limit;

clim = [10 30];
contour_interval = [clim(1):2:clim(2) 14];
colorbarname = 'Temperature (deg C)';

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

vari = get_hslice_J(filename,g,variname,layer_ind,'r');

vari(vari > temp_limit) = NaN;
vari_mask = vari.*mask2;

map_J(domain_case)

warning off
m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap('parula'); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
    clabel(cs, h);
end

c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);

end