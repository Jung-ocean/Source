%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc; close all;

fpath = '.\';
%fname = 'avg_0144.nc';
file = [fpath, fname];

varis = {'temp', 'salt', 'current'};
%lon_lim=[117.5 128]; lat_lim=[30 41];
lon_lim = [117.5 130.3]; lat_lim = [24.8 41];
depth_ind = 20; % 1 = bottom, 20 = surface

nc = netcdf(file);
lon_rho = nc{'lon_rho'}(:); lat_rho = nc{'lat_rho'}(:);
lon_u = nc{'lon_u'}(:); lat_u = nc{'lat_u'}(:);
lon_v = nc{'lon_v'}(:); lat_v = nc{'lat_v'}(:);
angle = nc{'angle'}(:); ocean_time = nc{'ocean_time'}(:);
temp = nc{'temp'}(:); salt = nc{'salt'}(:);
mask_rho = nc{'mask_rho'}(:); mask_u = nc{'mask_u'}(:); mask_v = nc{'mask_v'}(:);
u = nc{'u'}(:); v = nc{'v'}(:);
close(nc)

ftime = datestr(datenum(2013, 01, 01, 00, 00, 00) + ocean_time/60/60/24, 'yyyy-mm-dd')

mask2 = mask_rho./mask_rho;
masku2 = mask_u./mask_u;
maskv2 = mask_v./mask_v;
dum2=load('coast_sin.dat'); coa_lon=dum2(:,1); coa_lat=dum2(:,2);

for i = 1:2 %length(varis)
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
    
    if i == 1 | i==2
        savename = ([vari, '_', tys, tms,'_layer', dis, '_', domain_case]);
        eval([vari '_2d = squeeze(' vari '(depth_ind,:,:)).*mask2;'])
        
        figure('visible', 'off');
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
        vari = cell2mat(varis(i));
        savename = ([vari, ' ', ftime]);
        
        skip = 1;
        npts = [0 0 0 0];
        subsample = 10;
        vec_scale = 20; 
        
        u_surf = squeeze(u(depth_ind,:,:));
        v_surf = squeeze(v(depth_ind,:,:));
        [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_surf.*masku2,v_surf.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
        w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
        
        lim=[lon_lim lat_lim];
        fc=[.95 .95 .95 ];
        
        figure; hold on;
            set(gca,'ydir','nor');
            m_proj('miller','lon',[lim(1) lim(2)],'lat',[lim(3) lim(4)]);
            m_gshhs_i('color','k')
            m_gshhs_i('patch',fc )
        
        h1 = m_psliceuv(lon_rho,lat_rho,w,subsample, vec_scale,[.4 .4 .4]);
        set(h1,'linewidth',1 )
        
        m_text(117.8, 36.5,'0.5 m s^-^1','color','k','fontsize',12,'fontweight','bold','FontName', 'Times')    
        h1 = m_psliceuv(117.8 ,35.8  ,0.5, subsample, vec_scale,'k');
        set(h1,'linewidth',1 )
        
        m_grid('XTick',118:3:130,'YTick',25:3:44,'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
        
        title(savename, 'fontsize', 25)
        
        saveas(gcf, [savename,'.png'])
        %dpi = '-r1200'; print(gcf,dpi,'-dpng',savename)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Expanded figure
        lon_lim2 = [121 128]; lat_lim2 = [31 36];
        vec_scale2 = 10;
        lim2 = [lon_lim2 lat_lim2];
        
        figure; hold on;
            set(gca,'ydir','nor');
            m_proj('miller','lon',[lim2(1) lim2(2)],'lat',[lim2(3) lim2(4)]);
            m_gshhs_i('color','k')
            m_gshhs_i('patch',fc )
        
        h1 = m_psliceuv(lon_rho,lat_rho,w,subsample, vec_scale2,[.4 .4 .4]);
        set(h1,'linewidth',1 )
        
        m_text(127, 35.7,'0.5 m s^-^1','color','k','fontsize',12,'fontweight','bold','FontName', 'Times') 
        h1 = m_psliceuv(127 ,35.4 ,0.5, subsample, vec_scale2,'k');
        set(h1,'linewidth',1 )
        
        m_grid('XTick',lon_lim2(1):2:lon_lim2(2),'YTick',lat_lim2(1):2:lat_lim2(2),'linewi',2,'linest','none','tickdir','out','fontsize',20, 'fontweight','bold','FontName', 'Times');
        
        title(savename, 'fontsize', 25)
        
        saveas(gcf, [savename,'_expand.png'])
        %dpi = '-r1200'; print(gcf,dpi,'-dpng',savename)
    end
end