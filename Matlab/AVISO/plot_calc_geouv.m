clear; clc; close all

g = 10;
omega = 7.3e-5;

filepath = 'D:\Data\Satellite\AVISO\';
file4mdt = 'AVISO_daily_global_20200307.nc';
nc = netcdf(file4mdt);
sla = nc{'sla'}(:).*nc{'sla'}.scale_factor(:); + nc{'sla'}.add_offset(:);
adt = nc{'adt'}(:).*nc{'adt'}.scale_factor(:); + nc{'adt'}.add_offset(:);
close(nc)
mdt = adt - sla;
mdt(abs(mdt) > 1000) = NaN;

yyyy = 2011; ystr = num2str(yyyy);
domain_case = 'NP';

for mi = 1:12
    
    month = mi; mstr = num2char(mi,2);
    
    filename = ['AVISO_monthly_global_2011_2019.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    sla = nc{'sla'}(:).*nc{'sla'}.scale_factor(:); + nc{'sla'}.add_offset(:);
    time = nc{'time'}(:);
    lon_raw = nc{'longitude'}(:);
    lat_raw = nc{'latitude'}(:);
    close(nc);
    lat_cent = (lat_raw(1:end-1) + lat_raw(2:end))/2;
    
    f = 2.*omega.*sin(lat_raw.*pi/180);
    f_cent = 2.*omega.*sin(lat_cent.*pi/180);
    
    for li = 1:length(lat_raw)
        dx(:,li) = m_lldist(lon_raw, lat_raw(li) + zeros(size(lon_raw)))*1000;
    end
    
    dx_mat = dx';
    
    for li = 1:length(lon_raw)
        dy(li,:) = m_lldist(lon_raw(li) + zeros(size(lat_raw)), lat_raw)*1000;
    end
    
    dy_mat = dy';
    
    fy_mat = repmat(f, [1, size(dx_mat,2)]);
    fx_mat = repmat(f_cent, [1, size(dy_mat,2)]);
    
    [lon, lat] = meshgrid(lon_raw, lat_raw);
    
    time_vec = datevec(time + datenum(1950,1,1));
    index = find(time_vec(:,1) == yyyy & time_vec(:,2) == month);
    
    ADT = mdt + squeeze(sla(index,:,:));
    ADT_ydiff = diff(ADT,1);
    ADT_xdiff = diff(ADT,1,2);
    
    ug = -(g./fx_mat).*ADT_ydiff./dy_mat;
    vg = (g./fy_mat).*ADT_xdiff./dx_mat;
    
    ug_rho = zeros(size(lon));
    vg_rho = zeros(size(lat));
    
    ug_rho(2:end-1,:) = (ug(1:end-1,:) + ug(2:end,:))/2;
    ug_rho(1,:) = ug_rho(2,:); ug_rho(end,:) = ug_rho(end-1,:);
    
    vg_rho(:,2:end-1) = (vg(:,1:end-1) + vg(:,2:end))/2;
    vg_rho(:,1) = vg_rho(:,2); vg_rho(:,end) = vg_rho(:,end-1);
    
    ug_rho(abs(ug_rho) > 100) = NaN;
    vg_rho(abs(vg_rho) > 100) = NaN;
    
    u_mean = ug_rho;
    v_mean = vg_rho;
        
    figure; hold on
        
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