%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (Daily)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

load('daily_201308_02m.mat')
%figpath = 'G:\Model\ROMS\Output\ROMS_ECMWF\figure\';
figpath = '.\';

%lon_lim = [124 130]; lat_lim = [33 37]; % small domain
lon_lim = [117 130]; lat_lim = [27 41]; % large domain
lim = [lon_lim lat_lim];
fc = [.95 .95 .95 ];

for i = 1:3 %length(varis)
    for di = 1:15:endday
        if i == 1 % Temperature
            di_datenum = datenum(target_year, target_month, di, 0, 0, 0);
            contour_interval = [0:2:35];
            clim = [0 35];
            vari = 'temp_daily';
            titlename = ['Temp ',datestr(di_datenum, 'yyyymmdd'), ' ', num2str(depth), 'm'];
            colorbarname = 'Temperature (deg C)';
        elseif i == 2 % Salinity
            di_datenum = datenum(target_year, target_month, di, 0, 0, 0);
            contour_interval = [30:1:35];
            clim = [30 35];
            vari = 'salt_daily';
            titlename = ['Salt ',datestr(di_datenum, 'yyyymmdd'), ' ', num2str(depth), 'm'];
            colorbarname = 'Salinity';
        end
        
        if i == 1 || i==2
            savename = ([vari, '_', datestr(di_datenum, 'yyyymmdd'), '_', num2str(depth), 'm']);
            eval([vari '_2d = squeeze(' vari '(di,:,:)).*mask2;'])
            
            figure('visible', 'off'); hold on;
            set(gca,'ydir','nor');
            m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
            m_gshhs_i('color','k')
            m_pcolor(lon_rho, lat_rho, eval([vari '_2d'])); colormap('jet'); shading flat;
            [cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'w');
            clabel(cs, h);
            m_gshhs_i('patch',fc )
            c = colorbar; c.FontSize = 15;
            c.Label.String = colorbarname; c.Label.FontSize = 15;
            caxis(clim);
            m_grid('XTick',lim(1):2:lim(2),'YTick',lim(3):2:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
            
            title(titlename, 'fontsize', 25)
            
            saveas(gcf, [figpath, savename,'.png'])
            
        elseif i == 3
            di_datenum = datenum(target_year, target_month, di, 0, 0, 0);
            vari = 'current_daily';
            savename = ([vari, '_', datestr(di_datenum, 'yyyymmdd'), '_', num2str(depth), 'm']);
            titlename = ['Current ',datestr(di_datenum, 'yyyymmdd'), ' ', num2str(depth), 'm'];
            
            skip = 1;
            npts = [0 0 0 0];
            subsample = 10;
            vec_scale = 10;
            
            u_2d = squeeze(u_daily(di,:,:));
            v_2d = squeeze(v_daily(di,:,:));
            [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
            w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
            
            figure('visible', 'off'); hold on;
            set(gca,'ydir','nor');
            m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
            m_gshhs_i('color','k')
            m_gshhs_i('patch',fc )
            
            h1 = m_psliceuv(lon_rho,lat_rho,w,subsample, vec_scale,[.4 .4 .4]);
            set(h1,'linewidth',1 )
            
            m_text(127.3, 36.5,'0.5 m s^-^1','color','k','fontsize',12,'fontweight','bold','FontName', 'Times')
            h1 = m_psliceuv(128.3 ,36.5  ,0.5, subsample, vec_scale,'k');
            set(h1,'linewidth',1 )
            
            m_grid('XTick',lim(1):2:lim(2),'YTick',lim(3):2:lim(4),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
            
            title(titlename, 'fontsize', 25)
            
            saveas(gcf, [figpath, savename,'.png'])
        end
    end
    close all
end