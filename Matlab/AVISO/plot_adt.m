clear; clc; close all

domain_case = 'KODC_small';
colorbarname = 'Absolute Dynamic Topography (m)';

for yi = 2006:2015
    
    year = yi; ystr = num2str(yi);
    
    for mi = 7:7
        month = mi; mstr = num2char(month,2);
        
        clim = [0.5 1.5];
        contour_interval = [clim(1):0.1:clim(2)];
        
        filepath = '.\';
        filename = ['AVISO_daily_', ystr, '.nc'];
        file = [filepath, filename];
        
        nc = netcdf(file);
        adt = nc{'adt'}(:); adt_sf = nc{'adt'}.scale_factor(:);
        adt = adt.*adt_sf;
        u = nc{'ugos'}(:); u_sf = nc{'ugos'}.scale_factor(:);
        u = u.*u_sf;
        v = nc{'vgos'}(:); v_sf = nc{'vgos'}.scale_factor(:);
        v = v.*v_sf;
        time = nc{'time'}(:);
        lon_raw = nc{'longitude'}(:);
        lat_raw = nc{'latitude'}(:);
        close(nc);
        
        [lon, lat] = meshgrid(lon_raw, lat_raw);
        
        time_vec = datevec(time + datenum(1950,1,1));
        index = find(time_vec(:,1) == year & time_vec(:,2) == month);
        
        adt_mean = squeeze(mean(adt(index,:,:)));
        adt_mean(adt_mean < -1000) = NaN;
        
        figure; hold on
        map_J(domain_case)
        m_pcolor(lon, lat, adt_mean); colormap('parula'); shading flat;
        [cs, h] = m_contour(lon, lat, adt_mean, contour_interval, 'k');
        clabel(cs, h);
        
        c = colorbar; c.FontSize = 15;
        c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        saveas(gcf, ['adt_AVISO_', domain_case, '_', ystr, mstr, '.png'])
        
    end
    
end