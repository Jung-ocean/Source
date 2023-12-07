function ROMS_plot_zeta_function(filename, variname, casename, domain_case, contour)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_temp_function(filename, variname, depth_ind, casename, domain_case, contour)
%
%   filename: model output filename (usually netcdf format)
%   variname: zeta variable name in model output file (ex, 'zeta' ... )
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   contour: 'contour on' or 'contour off'
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nc = netcdf(filename);
if length(size(nc{variname})) == 2
    vari = nc{variname}(:,:);
elseif length(size(nc{variname})) == 3
    vari = nc{variname}(1,:,:);
end
close(nc)

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

%clim = [-0.5 0.5];
clim = [0 .5];
%contour_interval = [clim(1):0.02:clim(2)];
contour_interval = [0:.02:.2];
colorbarname = 'm';

vari_mask = vari.*mask2;

map_J(domain_case)

m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap('parula'); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
    h.LineWidth = 1;
    clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 400);   
end

c = colorbar; c.FontSize = 15;
c.Title.String = colorbarname; c.Title.FontSize = 15;
caxis(clim);

end