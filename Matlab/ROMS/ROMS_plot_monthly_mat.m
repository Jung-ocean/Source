%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc; close all;

load(filename)
%figpath = 'G:\Model\ROMS\Output\ROMS_ECMWF\figure\';
figpath = '.\';

domain_case = 'YECS_large';

depth_ind = 20;
dis = num2char(depth_ind, 2);

for i = 1:2 %length(varis)
    if i == 1 % Temperature
        contour_interval = [0:2:35];
        clim = [0 35];
        vari = 'temp_monthly';
        titlename = ['Temp monthly ',datestr(fdatenum, 'yyyymm'), ' layer ', dis];
        colorbarname = 'Temperature (deg C)';
    elseif i == 2 % Salinity
        contour_interval = [30:1:35];
        clim = [30 35];
        vari = 'salt_monthly';
        titlename = ['Salt monthly ',datestr(fdatenum, 'yyyymm'), ' layer ', dis];
        colorbarname = 'Salinity';
    end
    
    if i == 1 || i==2
        savename = ([vari, '_', tys, tms, '_layer', dis]);
        eval([vari '_2d = squeeze(' vari '(depth_ind,:,:)).*mask2;'])
        
        figure; hold on;
        map_J(domain_case)
        m_pcolor(lon_rho, lat_rho, eval([vari '_2d'])); colormap('jet'); shading flat;
        [cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'w');
        clabel(cs, h);
        m_gshhs_i('patch',fc )
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        m_grid('XTick',lim(1):6:lim(2),'YTick',lim(3):6:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
        
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [figpath, savename,'.png'])
        
    elseif i == 3
        vari = 'current_monthly';
        savename = ([vari, '_', tys, tms, '_layer', dis]);
        titlename = ['Current monthly ',datestr(fdatenum, 'yyyymm'), ' layer ', dis];
        
        skip = 1;
        npts = [0 0 0 0];
        subsample = 10;
        vec_scale = 15;
        
        u_2d = squeeze(u_monthly(depth_ind,:,:));
        v_2d = squeeze(v_monthly(depth_ind,:,:));
        [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
        w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
        
        figure; hold on;
        set(gca,'ydir','nor');
        m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
        m_gshhs_i('color','k')
        m_gshhs_i('patch',fc )
        
        h1 = m_psliceuv(lon_rho,lat_rho,w,subsample, vec_scale,[.4 .4 .4]);
        set(h1,'linewidth',1 )
        
        m_text(119, 45,'0.5 m s^-^1','color','k','fontsize',12,'fontweight','bold','FontName', 'Times')
        h1 = m_psliceuv(119 , 46, 0.5, subsample, vec_scale,'k');
        set(h1,'linewidth',1 )
        
        m_grid('XTick',lim(1):6:lim(2),'YTick',lim(3):6:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
        
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [figpath, savename,'.png'])
        
    end
end