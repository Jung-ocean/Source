%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (History)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

casename = 'DA';
title_head = 'Con';
figpath = '.\';
refdatenum = datenum(2013,1,1);

depth_ind = 40;
dis = num2char(depth_ind, 2);

g = grd('NWP');
mask_rho = g.mask_rho; mask2 = mask_rho./mask_rho;
mask_u = g.mask_u; masku2 = mask_u./mask_u;
mask_v = g.mask_v; maskv2 = mask_v./mask_v;
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
angle = g.angle;

filenum = [152:166];

for fi = filenum
    %     filename = ['his_ens01_', num2char(fi,4), '.nc'];
    %     nc = netcdf(filename);
    %     temp = nc{'temp'}(end,depth_ind,:,:);
    %     ot = nc{'ocean_time'}(end);
    %     dstr = datestr(refdatenum + ot/60/60/24, 'yyyymmddHH');
    %     close(nc)
    
    for i = 3:3 %length(varis)
        if i == 1 % Temperature
            contour_interval = [10:2:30];
            clim = [10 30];
            vari = 'temp';
            titlename = [title_head, ' temp ', dstr, ' layer', dis];
            colorbarname = 'Temperature (deg C)';
        elseif i == 2 % Salinity
            contour_interval = [30:1:35];
            clim = [30 35];
            vari = 'salt';
            titlename = ['Salt monthly ',tys, tms, ' layer', dis];
            colorbarname = 'Salinity';
        end
        
        if i == 1 || i==2
            savename = ([vari, '_', dstr,'_layer', dis]);
            
            figure;
            map_J('DA')
            m_pcolor(lon_rho, lat_rho, eval([vari '.*mask2'])); colormap('jet'); shading flat;
            %[cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'w');
            %clabel(cs, h);
            c = colorbar; c.FontSize = 15;
            c.Label.String = colorbarname; c.Label.FontSize = 15;
            caxis(clim);
            
            title(titlename, 'fontsize', 25)
            
            saveas(gcf, [figpath, savename,'.png'])
            
        elseif i == 3
            for ii = 1:8
                filename = ['his_', num2char(fi,4), '.nc'];
                nc = netcdf(filename);
                u = nc{'u'}(ii,depth_ind,:,:);
                v = nc{'v'}(ii,depth_ind,:,:);
                ot = nc{'ocean_time'}(ii);
                dstr = datestr(refdatenum + ot/60/60/24, 'yyyymmddHH');
                close(nc)
                
                vari = 'current';
                savename = ([vari, '_', dstr,'_layer', dis]);
                titlename = [title_head, ' current ', dstr, ' layer', dis];
                
                figure;
                map_J(casename)
                puv = puv_J(casename);
                
                u_2d = u;
                v_2d = v;
                [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,puv.skip,puv.npts);
                w = (u_rho+sqrt(-1).*v_rho).*mask_rho;
                
                h1 = m_psliceuv(lon_rho,lat_rho,w,puv.interval, puv.scale_factor,puv.color);
                set(h1,'linewidth',1 )
                
                h1 = m_psliceuv(puv.scale_Loc(1), puv.scale_Loc(2), puv.scale_value, 1, puv.scale_factor, 'k');
                m_text(puv.scale_text_Loc(1), puv.scale_text_Loc(2), puv.scale_text,'color','k','fontsize',12,'fontweight','bold','FontName', 'Times')
                
                set(h1,'linewidth',1 )
                
                title(titlename, 'fontsize', 25)
                
                saveas(gcf, [figpath, savename,'.png'])
            end
            
        end
    end
end