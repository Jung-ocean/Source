clear; clc; close all

casename = 'ECMWF_monthly';

yyyy = 2013; tys = num2char(yyyy,4);
mm = 7; tms = num2char(mm,2);

filepath_all = dir(['G:\Lab_forcing\',tys,tms,'*']);
filename = 'UM_yw3km_swrad.nc';

swrad_sum = zeros;
for i = 1:length(filepath_all)
    filepath = filepath_all(i).name;
    file = [filepath, '\', filename];
    nc = netcdf(file);
    lon = nc{'lon_rho'}(:); lat = nc{'lat_rho'}(:);
    swrad = nc{'swrad'}(:);
    close(nc)
    
    swrad_sum = swrad_sum + squeeze(sum(swrad(1:8,:,:)));
    
end
swrad_monthly = swrad_sum/length(filepath_all);

figure;
map_J(casename)

clim = [600 1300];
contour_interval = clim(1):100:clim(end);

m_pcolor(lon, lat, swrad_monthly); colormap('parula'); shading flat;
[cs, h] = m_contour(lon, lat, swrad_monthly, contour_interval, 'k', 'LineWidth', 1.5);
clabel(cs, h, 'FontWeight', 'bold');
c = colorbar; c.FontSize = 15;
c.Label.String = 'Temperature (deg C)'; c.Label.FontSize = 15;
caxis(clim);

title(['UM monthly swrad ', tys, tms], 'fontsize', 15)

saveas(gcf, ['UM_monthly_swrad_', tys, tms, '_', casename, '.png'])

disp([' End plotting ', tys, tms])