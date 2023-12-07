clear; clc; close all

casename = 'YECS_small';

yyyy = 2013; tys = num2char(yyyy,4);
mm = 2; tms = num2char(mm,2);

filepath_all = dir(['G:\Lab_forcing\',tys,tms,'*']);
filename = 'UM_yw3km_Tair.nc';

Tair_sum = zeros;
for i = 1:length(filepath_all)
    filepath = filepath_all(i).name;
    file = [filepath, '\', filename];
    nc = netcdf(file);
    lon = nc{'lon_rho'}(:); lat = nc{'lat_rho'}(:);
    Tair = nc{'Tair'}(:);
    close(nc)
    
    Tair_sum = Tair_sum + squeeze(mean(Tair));
    
end
Tair_monthly = Tair_sum/length(filepath_all);

figure;
map_J(casename)

switch mm
    case {7, 8}
        clim = [20 30];
        contour_interval = clim(1):2:clim(2);
    case {1, 2}
        clim = [-5 10];
        contour_interval = clim(1):2:clim(2);
end

m_pcolor(lon, lat, Tair_monthly); colormap('parula'); shading flat;
[cs, h] = m_contour(lon, lat, Tair_monthly, contour_interval, 'k', 'LineWidth', 1.5);
clabel(cs, h, 'FontWeight', 'bold');
c = colorbar; c.FontSize = 15;
c.Label.String = 'Temperature (deg C)'; c.Label.FontSize = 15;
caxis(clim);

title(['UM monthly temp ', tys, tms], 'fontsize', 15)

saveas(gcf, ['UM_monthly_temp_', tys, tms, '_', casename, '.png'])

disp([' End plotting ', tys, tms])