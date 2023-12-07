%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load('monthly_201307_30m.mat')
%figpath = 'G:\Model\ROMS\Output\ROMS_ECMWF\figure\';
figpath = '.\';

casename = 'YECS_small';

for i = 1:3 %length(varis)
    if i == 1 % Temperature
        contour_interval = [0:2:35];
        clim = [0 35];
        vari = 'temp_monthly';
        titlename = ['Temp monthly ', tys, tms, ' ', num2str(depth), 'm'];
        colorbarname = 'Temperature (deg C)';
    elseif i == 2 % Salinity
        contour_interval = [30:1:35];
        clim = [30 35];
        vari = 'salt_monthly';
        titlename = ['Salt monthly ', tys, tms, ' ', num2str(depth), 'm'];
        colorbarname = 'Salinity';
    end
    
    if i == 1 || i==2
        savename = ([vari, '_', tys, tms, '_', num2str(depth), 'm']);
        eval([vari '_2d = squeeze(' vari '(:,:)).*mask2;'])
        
        map_J(casename)
        
        m_pcolor(lon_rho, lat_rho, eval([vari '_2d'])); colormap('jet'); shading flat;
        [cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'w');
        clabel(cs, h);
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
       
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [figpath, savename,'.png'])
        
    elseif i == 3
        vari = 'current_monthly';
        savename = ([vari, '_', tys, tms, '_', num2str(depth), 'm']);
        titlename = ['Current monthly ',tys, tms, ' ', num2str(depth), 'm'];

        
        
        u_2d = u_monthly;
        v_2d = v_monthly;
        %[u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
        u_rho = u_2d; v_rho = v_2d;
        w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
        
        map_J(casename)
        puv = puv_J(casename);
        
        h1 = m_psliceuv(lon_rho,lat_rho,w,puv.interval, puv.scale_factor,puv.color);
        set(h1,'linewidth',1 )
                
        h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, 'k');
        m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color','k','fontsize',12,'fontweight','bold','FontName', 'Times')
        
        set(h1,'linewidth',1 )
        
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [figpath, savename,'.png'])
        
    end
end