function ROMS_plot_current_bar_function(filename, variname_u, variname_v, layer_ind, casename, domain_case, linewidth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROMS_plot_current_function(filename, variname, depth_ind, casename, domain_case)
%
%   filename: model output filename (usually netcdf format)
%   variname_u: zonal current variable name in model output file (ex, 'u', 'ubar' ... )
%   variname_v: meridional current variable name in model output file (ex, 'v', 'vbar' ... )
%   layer_ind: layer number you want to plot
%   casename: model case (grid)
%   domain_case: domain case (figure)
%   linewidth: arrow linewidth
%
%   J.Jung
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = grd(casename);
masku2 = g.mask_u./g.mask_u;
maskv2 = g.mask_v./g.mask_v;

skip = 1;
npts = [0 0 0 0];

nc = netcdf(filename);
if length(size(nc{variname_u})) == 3
    ubar = nc{'ubar'}(:);
    vbar = nc{'vbar'}(:);
elseif length(size(nc{variname_u})) == 4
    ubar = nc{'ubar'}(:);
    vbar = nc{'vbar'}(:);
end
close(nc)

[ubar_rho,vbar_rho,lon,lat,mask] = uv_vec2rho(ubar.*masku2,vbar.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

ubar_eastward = ubar_rho;
ubar_eastward(ubar_eastward < 0) = NaN;
ubar_westward = ubar_rho;
ubar_westward(ubar_westward > 0) = NaN;

wbar_eastward = (ubar_eastward+sqrt(-1).*vbar_rho).*g.mask_rho;
wbar_westward = (ubar_westward+sqrt(-1).*vbar_rho).*g.mask_rho;

map_J(domain_case)
puv = puv_J(['bar_', domain_case]);

h1 = m_psliceuv(g.lon_rho,g.lat_rho,wbar_eastward,puv.interval, puv.scale_factor, [0.8510 0.3255 0.0980]);
set(h1,'linewidth', linewidth)

h1 = m_psliceuv(g.lon_rho,g.lat_rho,wbar_westward,puv.interval, puv.scale_factor, [0 0.4471 0.7412]);
set(h1,'linewidth', linewidth)

h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color',puv.scale_text_color,'fontsize', puv.scale_text_fontsize,'fontweight','bold','FontName','Times')
set(h1,'linewidth', linewidth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%