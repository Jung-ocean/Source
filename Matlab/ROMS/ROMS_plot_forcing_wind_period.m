%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS wind forcing
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath = 'G:\Model\ROMS\Case\NWP\input\';
ufilename = 'Uwind_NWP_ECMWF_2013.nc';
vfilename = 'Vwind_NWP_ECMWF_2013.nc';

domain_case = 'KODC_small';

g = grd('NWP');

[lon_lim, lat_lim] = domain_J(domain_case);
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);
lon = g.lon_rho(lat_ind, lon_ind); lat = g.lat_rho(lat_ind, lon_ind);

mask_nan = g.mask_rho(lat_ind, lon_ind)./g.mask_rho(lat_ind, lon_ind);

refday = datenum(2013,1,1,0,0,0);
target_year = 2013; tys = num2str(target_year);

for di = 21:22
    
    datenum_start = datenum(2013,7,di,0,0,0); dss = datestr(datenum_start, 'yyyymmdd');
    datenum_end = datenum(2013,7,di,24,0,0); des = datestr(datenum_end, 'yyyymmdd');
    
    ot_start = datenum_start - refday;
    ot_end = datenum_end - refday;
    
    ufile = [filepath, ufilename];
    vfile = [filepath, vfilename];
    
    unc = netcdf(ufile);
    ot = unc{'Uwind_time'}(:);
    
    vnc = netcdf(vfile);
    
    index_start = find(ot == ot_start);
    index_end = find(ot == ot_end);
    
    u = unc{'Uwind'}(index_start:index_end, lat_ind, lon_ind);
    v = vnc{'Vwind'}(index_start:index_end, lat_ind, lon_ind);
    
    u_mean = squeeze(mean(u)).*mask_nan;
    v_mean = squeeze(mean(v)).*mask_nan;
    
    figure;
    map_J(domain_case);
    puv = puv_J(['ECMWF_', domain_case]);
    
    % Target figure
    w_target = squeeze((u_mean+sqrt(-1).*v_mean));
    h_target = m_psliceuv(lon, lat, w_target, puv.interval, puv.scale_factor, puv.color);
    
    % Scale
    h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
    
    % Text
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'fontweight', 'bold', 'color', puv.scale_text_color)
    
    title(['Wind ', dss], 'fontsize', 20)
    %saveas(gcf, ['wind_', dss, '.png'])
    
    close(unc)
    close(vnc)
    
end