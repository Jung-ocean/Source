function ROMS_plot_current_function(filename, variname_u, variname_v, layer_ind, casename, domain_case, linewidth)
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

if layer_ind > 0
    nc = netcdf(filename);
    if length(size(nc{variname_u})) == 3
        u_2d = nc{variname_u}(layer_ind,:,:);
        v_2d = nc{variname_v}(layer_ind,:,:);
    elseif length(size(nc{variname_u})) == 4
        u_2d = nc{variname_u}(1,layer_ind,:,:);
        v_2d = nc{variname_v}(1,layer_ind,:,:);
    end
    close(nc)
elseif layer_ind < 0
    u_2d = get_hslice_J(filename,g,variname_u,layer_ind,'u');
    v_2d = get_hslice_J(filename,g,variname_v,layer_ind,'v');
end

[u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
w = (u_rho+sqrt(-1).*v_rho).*g.mask_rho;

map_J(domain_case)
warning off

puv = puv_J(domain_case);

h1 = m_psliceuv(g.lon_rho,g.lat_rho,w,puv.interval, puv.scale_factor,puv.color);
set(h1,'linewidth', linewidth)

h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color',puv.scale_text_color,'fontsize', puv.scale_text_fontsize,'fontweight','bold','FontName','Times')
set(h1,'linewidth', linewidth)