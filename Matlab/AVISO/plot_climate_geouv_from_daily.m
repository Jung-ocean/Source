clear; clc; close all

yyyy_all = 2011:2019;
mm_all = 1:12;
domain_case = 'NWP';

for mi = 1:length(mm_all)
    
    mm = mm_all(mi); mstr = num2str(mm,'%02i');
    
    filepath = '.\';
    
    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);
        ufilename = ['AVISO_daily_NP_ugos_', ystr, '.nc'];
        ufile = [filepath, ufilename];
        unc = netcdf(ufile);
        time = unc{'time'}(:);
        time_vec = datevec(time + datenum(1950,1,1));
        index = find(time_vec(:,2) == mm);
        
        u = unc{'ugos'}(index,:,:); u_sf = unc{'ugos'}.scale_factor(:);
        if ~isempty(u_sf)
            u = u.*u_sf;
        end
        close(unc)
        
        vfilename = ['AVISO_daily_NP_vgos_', ystr, '.nc'];
        vfile = [filepath, vfilename];
        vnc = netcdf(vfile);
        v = vnc{'vgos'}(index,:,:); v_sf = vnc{'vgos'}.scale_factor(:);
        if ~isempty(v_sf)
            v = v.*v_sf;
        end
        lon_raw = vnc{'longitude'}(:);
        lat_raw = vnc{'latitude'}(:);
        close(vnc);
        
        u_monthly(yi,:,:) = mean(u);
        v_monthly(yi,:,:) = mean(v);
    end
    
    u_climate = squeeze(mean(u_monthly));
    v_climate = squeeze(mean(v_monthly));
    
    [lon, lat] = meshgrid(lon_raw, lat_raw);
    
    u_climate(u_climate < -1000) = NaN;
    v_climate(v_climate < -1000) = NaN;
    
    figure; hold on
    
    skip = 1;
    npts = [0 0 0 0];
    
    w = (u_climate+sqrt(-1).*v_climate);
    
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
    
    saveas(gcf,['geouv_AVISO_', domain_case, '_climate',  mstr, '.png'])
    
end