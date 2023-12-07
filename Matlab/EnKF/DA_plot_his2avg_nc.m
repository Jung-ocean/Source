%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot ROMS Lab model output avgerage file variables (History)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

title_head = 'Con';
figpath = '.\';
refdatenum = datenum(2003,1,1);

depth_ind = 40;
dis = num2char(depth_ind, 2);

g = grd('NWP');
mask_rho = g.mask_rho; mask2 = mask_rho./mask_rho;
mask_u = g.mask_u; masku2 = mask_u./mask_u;
mask_v = g.mask_v; maskv2 = mask_v./mask_v;
lon_rho = g.lon_rho; lat_rho = g.lat_rho;
angle = g.angle;

filenum = [152, 166];

for fi = filenum
    %filename = ['before_ens01_step', num2char(fi,2), '_ini.nc'];
    
    filename = ['his_', num2char(fi,4), '.nc'];
    nc = netcdf(filename);
    ot = nc{'ocean_time'}(:);
    if length(ot) == 25
        startot = 2;
    else
        startot = 1;
    end
    temp = squeeze(mean(nc{'temp'}(startot:end,depth_ind,:,:)));
    dstr = datestr(refdatenum + ot(startot)/60/60/24, 'yyyymmdd');
    close(nc)
    
    for i = 1:1 %length(varis)
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
            plot_point_2017('2017');
            
            saveas(gcf, [figpath, savename,'.png'])
            
        elseif i == 3
            vari = 'current';
            savename = ([vari, '_', tys, tms, '_layer', dis]);
            titlename = ['Current ',tys, tms, ' layer', dis];
            
            skip = 1;
            npts = [0 0 0 0];
            subsample = 10;
            vec_scale = 15;
            
            u_2d = squeeze(u(depth_ind,:,:));
            v_2d = squeeze(v(depth_ind,:,:));
            [u_rho,v_rho,lon,lat,mask] = uv_vec2rho(u_2d.*masku2,v_2d.*maskv2,lon_rho,lat_rho,angle,mask_rho,skip,npts);
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
end