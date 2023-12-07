clear; clc; close all

domain_case = 'YECS_large';
colorbarname = 'Sea Level Anomaly (m)';

filepath = '.\';
filename = ['AVISO_monthly_NWP_1993_2019.nc'];
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

for yi = 1993:2001
    year = yi; ystr = num2str(year);
    
for mi = 1:6
    month = mi; mstr = num2char(month,2);
    
    clim = [-0.3 0.3];
    contour_interval = [clim(1):0.1:clim(2)];
    
    index = find(time_vec(:,1) == year & time_vec(:,2) == month);
    
    sla_mean = squeeze(mean(sla(index,:,:),1));
    sla_mean(sla_mean < -1000) = NaN;
    
    figure; hold on
    map_J(domain_case)
    m_pcolor(lon, lat, sla_mean); colormap('redblue2'); shading flat;
    [cs, h] = m_contour(lon, lat, sla_mean, contour_interval, 'k');
    clabel(cs, h, 'FontSize', 15);
    
    c = colorbar; c.FontSize = 15;
    c.Label.String = colorbarname; c.Label.FontSize = 15;
    caxis(clim);
    
    m_gshhs_i('patch', [.7 .7 .7])
    saveas(gcf, ['sla_AVISO_', domain_case, '_', ystr, mstr, '.png'])
    
end

end