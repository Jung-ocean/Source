clear; clc; close all

yyyy = 2019; ystr = num2str(yyyy);
domain_case = 'NWP';

for mi = 1:12
    
    month = mi; mstr = num2char(mi,2);
    
    filepath = '.\';
    ufilename = ['AVISO_daily_NP_ugos_', ystr, '.nc'];
    ufile = [filepath, ufilename];
    
    unc = netcdf(ufile);
    u = unc{'ugos'}(:); u_sf = unc{'ugos'}.scale_factor(:);
    if ~isempty(u_sf)
        u = u.*u_sf;
    end
    close(unc)
    
    vfilename = ['AVISO_daily_NP_vgos_', ystr, '.nc'];
    vfile = [filepath, vfilename];
    vnc = netcdf(vfile);
    v = vnc{'vgos'}(:); v_sf = vnc{'vgos'}.scale_factor(:);
    if ~isempty(v_sf)
        v = v.*v_sf;
    end
    time = vnc{'time'}(:);
    lon_raw = vnc{'longitude'}(:);
    lat_raw = vnc{'latitude'}(:);
    close(vnc);
    
    [lon, lat] = meshgrid(lon_raw, lat_raw);
    
    time_vec = datevec(time + datenum(1950,1,1));
    index = find(time_vec(:,1) == yyyy & time_vec(:,2) == month);
    
    u_mean = squeeze(mean(u(index,:,:)));
    u_mean(u_mean < -1000) = NaN;
    v_mean = squeeze(mean(v(index,:,:)));
    v_mean(v_mean < -1000) = NaN;
    
    figure; hold on
    
    skip = 1;
    npts = [0 0 0 0];
    
    w = (u_mean+sqrt(-1).*v_mean);
    
    map_J(domain_case)
    puv = puv_J(['AVISO_',domain_case]);
    
    h1 = m_psliceuv(lon,lat,w,puv.interval, puv.scale_factor,puv.color);
    set(h1,'linewidth', 1)
    
    h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, puv.scale_color);
    m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color',puv.scale_text_color,'fontsize', puv.scale_text_fontsize,'fontweight','bold','FontName','Times')
    set(h1,'linewidth', 1)
    
    %==========================================================================
    % g = grd('NWP_ver41');
    %
    % [cs, h] = m_contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, [50 100 200], 'r', 'linewidth', 2);
    % clabel(cs, h);
    
    saveas(gcf,['geouv_AVISO_', domain_case, '_', ystr,  mstr, '.png'])
    
end