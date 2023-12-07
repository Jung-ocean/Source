%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (Yearly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

figpath = '.\';
casename = 'NWP';
domain_case = 'DA';
depth_ind = 40;
dis = num2char(depth_ind, 2);

yi = 2016; tys = num2str(yi);
%mi = 1;

for mi = 1:12
    
    tms = num2char(mi,2);
    filename = ['monthly_', tys, tms, '.nc'];
    ncload(filename)
    
    u_surf_all(mi,:,:) = squeeze(u(depth_ind,:,:));
    v_surf_all(mi,:,:) = squeeze(v(depth_ind,:,:));
    temp_surf_all(mi,:,:) = squeeze(temp(depth_ind,:,:));
    
end
u_surf_yearly = squeeze(mean(u_surf_all)); clearvars u_surf_all
v_surf_yearly = squeeze(mean(v_surf_all)); clearvars v_surf_all
temp_surf_yearly = squeeze(mean(temp_surf_all)); clearvars temp_surf_all

g = grd(casename);
mask_rho = g.mask_rho; mask2 = mask_rho./mask_rho;
mask_u = g.mask_u; masku2 = mask_u./mask_u;
mask_v = g.mask_v; maskv2 = mask_v./mask_v;
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
angle = g.angle;

for i = 3:3 %length(varis)
    if i == 1 % Temperature
        contour_interval = [0:2:35];
        clim = [0 35];
        vari = 'temp';
        titlename = ['Temp monthly ',tys, tms, ' layer', dis];
        colorbarname = 'Temperature (deg C)';
    elseif i == 2 % Salinity
        contour_interval = [30:1:35];
        clim = [30 35];
        vari = 'salt';
        titlename = ['Salt monthly ',tys, tms, ' layer', dis];
        colorbarname = 'Salinity';
    end
    
    if i == 1 || i==2
        savename = ([vari, '_', tys, tms,'_layer', dis, '_', domain_case]);
        eval([vari '_2d = squeeze(' vari '(depth_ind,:,:)).*mask2;'])
        
        figure;
        map_J(domain_case)
        
        m_pcolor(lon_rho, lat_rho, eval([vari '_2d'])); colormap('jet'); shading flat;
        [cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'w');
        clabel(cs, h);
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [figpath, savename,'.png'])
        
    elseif i == 3
        vari = 'current';
        savename = ([vari, '_', tys, '_layer', dis, '_', domain_case]);
        titlename = ['Current ',tys, ' layer', dis];
        
        skip = 1;
        npts = [0 0 0 0];
        subsample = 10;
        vec_scale = 15;
        
        u_2d = u_surf_yearly;
        v_2d = v_surf_yearly;
        [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
        w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
        
        speed_surf_yearly = sqrt(u_rho.*u_rho + v_rho.*v_rho);
        
        figure;
        map_J(domain_case)
        puv = puv_J(domain_case);
        
        h1 = m_psliceuv(lon_rho,lat_rho,w,puv.interval, puv.scale_factor,puv.color);
        set(h1,'linewidth', 1.2)
        
        h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, 'k');
        m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color','k','fontsize',12,'fontweight','bold','FontName', 'Times')
        
        set(h1,'linewidth', 1.2)
        
        title(titlename, 'fontsize', 25)
        
        %saveas(gcf, [figpath, savename,'.png'])
        
    end
end

% Plot speed
figure;
map_J(domain_case)

m_pcolor(lon_rho, lat_rho, speed_surf_yearly.*mask2); colormap('jet'); shading flat;
c = colorbar; c.FontSize = 15;
c.Label.String = 'Speed (m/s)'; c.Label.FontSize = 15;
caxis([0 1.5]);

title('Speed 2016 layer40', 'fontsize', 25)

%saveas(gcf, [figpath, 'speed_2016_layer40_DA.png'])
save yearly_2016.mat lat_rho lon_rho mask2 temp_surf_yearly speed_surf_yearly