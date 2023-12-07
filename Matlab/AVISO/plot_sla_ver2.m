clear; clc; close all

year_mean = 2006:2015;
year_target = 2013;

domain_case = 'KODC_small';
colorbarname = 'Sea Level Anomaly (m)';

clim = [-0.1 0];
contour_interval = [clim(1):0.1:clim(2)];

for mi = 7:8
    
    month = mi; mstr = num2char(month,2);
    
    for yi = 1:length(year_mean)
        year = year_mean(yi); ystr = num2str(year);
        
        filepath = '.\';
        filename = ['AVISO_daily_', ystr, '.nc'];
        file = [filepath, filename];
        
        nc = netcdf(file);
        adt = nc{'adt'}(:); adt_sf = nc{'adt'}.scale_factor(:);
        adt = adt.*adt_sf;
        sla = nc{'sla'}(:); sla_sf = nc{'sla'}.scale_factor(:);
        sla = sla.*sla_sf;
        time = nc{'time'}(:);
        lon_raw = nc{'longitude'}(:);
        lat_raw = nc{'latitude'}(:);
        close(nc);
        
        [lon, lat] = meshgrid(lon_raw, lat_raw);
        
        time_vec = datevec(time + datenum(1950,1,1));
        index = find(time_vec(:,1) == year & time_vec(:,2) == month);
        
        adt_mean = squeeze(mean(adt(index,:,:)));
        adt_mean(adt_mean < -1000) = NaN;
        
        sla_mean = squeeze(mean(sla(index,:,:)));
        sla_mean(sla_mean < -1000) = NaN;
        
        adt_all(yi,:,:) = adt_mean;
        
        if year == year_target
            adt_target = adt_mean;
            sla_target = sla_mean;
        end
        
    end
    
    mdt = squeeze(mean(adt_all));
    sla_calc = adt_target - mdt;
    
    figure; hold on
    map_J(domain_case)
    m_pcolor(lon, lat, sla_calc); colormap('redblue'); shading flat;
    [cs, h] = m_contour(lon, lat, sla_calc, contour_interval, 'k');
    clabel(cs, h);
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
    saveas(gcf, ['ver2_sla_AVISO_', domain_case, '_', num2str(year_target), mstr, '.png'])
    
end