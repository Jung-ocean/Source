%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS wind forcing
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath = 'G:\Model\ROMS\Case\NWP\input\';
ufilename = 'Uwind_NWP_ECMWF_avgdir.nc';
vfilename = 'Vwind_NWP_ECMWF_avgdir.nc';

domain_case = 'YECS_large';

g = grd('NWP');

[lon_lim, lat_lim] = domain_J(domain_case);
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);
lon = g.lon_rho(lat_ind, lon_ind); lat = g.lat_rho(lat_ind, lon_ind);

mask_nan = g.mask_rho(lat_ind, lon_ind)./g.mask_rho(lat_ind, lon_ind);

refday = datenum(2013,1,1,0,0,0);
target_year = 2013; tys = num2str(target_year);
month_all = 7:8;

ufile = [filepath, ufilename];
vfile = [filepath, vfilename];

unc = netcdf(ufile);
ot = unc{'Uwind_time'}(:);

vnc = netcdf(vfile);

for mi = 1:length(month_all)
    target_month = month_all(mi); tms = num2char(target_month,2);
    endday = eomday(target_year, target_month);
    
    time_start = datenum(target_year, target_month, 1) - refday;
    time_end = datenum(target_year, target_month, endday) - refday;
    
    index_start = find(ot == time_start);
    index_end = find(ot == time_end);
        
    u = unc{'Uwind'}(index_start:index_end, lat_ind, lon_ind);
    v = vnc{'Vwind'}(index_start:index_end, lat_ind, lon_ind);
    
    u_monthly = squeeze(mean(u)).*mask_nan;
    v_monthly = squeeze(mean(v)).*mask_nan;
    
    figure;
    map_J(domain_case);
    puv = puv_J(['ECMWF_', domain_case]);
    
    % Target figure
    w_target = squeeze((u_monthly+sqrt(-1).*v_monthly));
    h_target = m_psliceuv(lon, lat, w_target, puv.interval, puv.scale_factor, puv.color);
    
    % Scale
    h_scale = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
    
    % Text
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text, 'fontweight', 'bold', 'color', puv.scale_text_color)
    
    title(['Monthly wind\_2013', tms], 'fontsize', 20)
end

close(unc)
close(vnc)