clear; clc; close all;

yyyy = 2013; tys = num2str(yyyy);
month = 8:8;
casename = 'YECS_small';

for mi = month(1):month(end)
    tms = num2char(mi,2);
    
    depth = 50;
    depth_str = num2char(depth,2);
    load(['monthly_', tys, tms, '_', depth_str, 'm.mat'])
    
    for i = 1:2 %length(varis)
        if i == 1 % Temperature
            contour_interval = [0:2:35];
            clim = [0 35];
            vari = 'temp';
            titlename = ['Temp ',tys, tms, ' ', depth_str, 'm combi'];
            colorbarname = 'Temperature (deg C)';
        elseif i == 2 % Salinity
            contour_interval = [30:1:35];
            clim = [30 35];
            vari = 'salt';
            titlename = ['Salt ',tys, tms, ' ', depth_str, 'm combi'];
            colorbarname = 'Salinity';
        end
        
        savename = ([vari, '_monthly_', tys,tms,'_',depth_str,'m_combi']);
        
        eval([vari '_2d = ', vari, '_monthly.*mask2;'])
        
        ncload(['monthly_', tys,tms, '.nc']);
        background_vari = eval(vari);
        
        b_vari_value = squeeze(background_vari(1,:,:)).*mask2;
        
        eval(['nanind = find(isnan(', vari, '_2d) == 1);'])
        eval([vari '_2d(nanind) = b_vari_value(nanind);'])
        
        map_J(casename)
        
        m_pcolor(lon_rho, lat_rho, eval([vari '_2d'])); colormap('jet'); shading flat
        [cs, h] = m_contour(lon_rho, lat_rho, eval([vari '_2d']), contour_interval, 'k');
        clabel(cs, h);
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        title(titlename, 'fontsize', 25)
        
        saveas(gcf, [savename,'.png'])
    end
end