clear; clc; close all

domain_case = 'southern';
colorbarname = 'cm';

year_all = 2006:2015;
month_all = 7:8;
plotyear = [9999,2013];

for yi = 1:length(year_all)
    
    year = year_all(yi); ystr = num2str(year)
    
    for mi = 1:length(month_all)
        month = month_all(mi); mstr = num2char(month,2);
        
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
        
        adt_monthly(yi,mi,:,:) = adt_mean;
    end
end

clim = [0 15];
contour_interval = [clim(1):5:clim(2)];

for pi = 1:length(plotyear)
    year = plotyear(pi);
    if year == 9999
        data_all = squeeze(mean(adt_monthly)); ystr = 'avg'; titlestr = 'climate';
    else
        ystr = num2str(year); titlestr = ystr;
        index = find(year == year_all);
        data_all = squeeze(adt_monthly(index,:,:,:));
    end
    data = squeeze(data_all(2,:,:) - data_all(1,:,:));
    
    data = data*100;

        figure; hold on
        map_J(domain_case)
        m_pcolor(lon, lat, data); colormap('msl'); shading flat;
        [cs, h] = m_contour(lon, lat, data, contour_interval, 'k');
        h.LineWidth = 1;
        clabel(cs, h, 'FontSize', 25, 'FontWeight', 'bold', 'LabelSpacing', 200);
        
        %c = colorbar; c.FontSize = 15;
        %c.Label.String = colorbarname; c.Label.FontSize = 15;
        caxis(clim);
        
        title(['SLD (Aug. - Jul. ', titlestr, ')'], 'FontSize', 25, 'FontWeight', 'bold')
        
        setposition([domain_case, '_obs'])
        m_gshhs_i('patch', [.7 .7 .7])
        %saveas(gcf, ['diff_sameyear_adt_AVISO_', domain_case, '_', ystr, mstr, '.png'])
end