function ROMS_plot_sla_function(filename, variname, casename, domain_case, contour)
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
mdtfile = 'G:\OneDrive - SNU\Model\ROMS\Case\EYECS\output\exp_HYCOM\20190904\avg\yearly.nc';
mnc = netcdf(mdtfile);

nc = netcdf(filename);
if length(size(nc{variname})) == 2
    vari = nc{variname}(:,:);
    mdt = mnc{variname}(:,:);
elseif length(size(nc{variname})) == 3
    vari = nc{variname}(1,:,:);
    mdt = mnc{variname}(1,:,:);
end
close(nc)

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

%clim = [-0.5 0.5];
clim = [0 .3];
contour_interval = [clim(1):0.05:clim(2)];
colorbarname = 'Sea Level Anomaly (m)';

vari_mask = (vari-mdt).*mask2;

map_J(domain_case)

m_pcolor(g.lon_rho, g.lat_rho, vari_mask); colormap('redblue'); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_mask, contour_interval, 'k');
    clabel(cs, h);
end

c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);

end