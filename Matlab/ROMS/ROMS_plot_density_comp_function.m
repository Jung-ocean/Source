function ROMS_plot_density_comp_function(filename, layer_ind, casename, domain_case, contour)
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

clim = [15 28];
contour_interval = [clim(1):2:clim(2)];
colorbarname = '\sigma_t';
colormapname = 'jet';

g = grd(casename);
mask2 = g.mask_rho./g.mask_rho;

nc = netcdf(filename);
if length(size(nc{'temp'})) == 3
    temp_bot = nc{'temp'}(1,:,:);
    salt_bot = nc{'salt'}(1,:,:);
elseif length(size(nc{'temp'})) == 4
    temp_bot = nc{'temp'}(1,1,:,:);
    salt_bot = nc{'salt'}(1,1,:,:);
end
zeta = nc{'zeta'}(:);
close(nc)

temp_bot_mask = temp_bot.*mask2;
salt_bot_mask = salt_bot.*mask2; salt_bot_mask(salt_bot_mask < 0) = 0;

depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
pres_bot = sw_pres(g.mask_rho.*squeeze(depth(1,:,:)), g.lat_rho);
pden_bot = sw_pden_ROMS(salt_bot_mask, temp_bot_mask, pres_bot, 0);

vari_bot = pden_bot - 1000;
vari_bot_mask = vari_bot.*mask2;
%======
temp = get_hslice_J(filename, g, 'temp', layer_ind, 'r');
salt = get_hslice_J(filename, g, 'salt', layer_ind, 'r');

pres = sw_pres(layer_ind*ones(size(g.lat_rho)), g.lat_rho);
pden = sw_pden_ROMS(salt, temp, pres, 0);

vari = pden - 1000;
vari_mask = vari.*mask2;

vari_comp = vari_mask;
index_nan = isnan(vari_comp) == 1;
vari_comp(index_nan) = vari_bot_mask(index_nan);

map_J(domain_case)

warning off
m_pcolor(g.lon_rho, g.lat_rho, vari_comp); colormap(colormapname); shading flat;

if strcmp(contour, 'contour on')
    [cs, h] = m_contour(g.lon_rho, g.lat_rho, vari_comp, contour_interval, 'k');
    clabel(cs, h);
end

c = colorbar; c.FontSize = 15;
c.Label.String = colorbarname; c.Label.FontSize = 15;
caxis(clim);

end