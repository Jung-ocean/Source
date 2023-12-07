clear; clc; close all

domain_case = 'SS_sla';
colorbarname = 'Sea Level Anomaly (m)';

for yi = 2013:2013
    year = yi; ystr = num2str(year);
    
for mi = 7:8
    month = mi; mstr = num2char(month,2);
    
    clim = [0 0.3];
    contour_interval = [clim(1):0.05:clim(2)];
    
    filepath = '.\';
    filename = ['AVISO_daily_', ystr, '.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    sla = nc{'sla'}(:); sla_sf = nc{'sla'}.scale_factor(:);
    sla = sla.*sla_sf;
    time = nc{'time'}(:);
    lon_raw = nc{'longitude'}(:);
    lat_raw = nc{'latitude'}(:);
    close(nc);
    
    [lon, lat] = meshgrid(lon_raw, lat_raw);
    
    time_vec = datevec(time + datenum(1950,1,1));
    index = find(time_vec(:,1) == year & time_vec(:,2) == month);
    
    sla_mean = squeeze(mean(sla(index,:,:)));
    sla_mean(sla_mean < -1000) = NaN;
    
    figure; hold on
    map_J(domain_case)
    m_pcolor(lon, lat, sla_mean); colormap('redblue2'); shading flat;
    [cs, h] = m_contour(lon, lat, sla_mean, contour_interval, 'k');
    clabel(cs, h);
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
    m_gshhs_i('patch', [.7 .7 .7])
    saveas(gcf, ['sla_AVISO_', domain_case, '_', ystr, mstr, '.png'])
    
end

end