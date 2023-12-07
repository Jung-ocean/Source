clear; clc; close all

grid_case = 'EYECS_20220110';
domain_case = 'southern';

switch domain_case
    case 'Luzon'
        interval_contour = [0 1000 4000 5000];
    case 'onshore'
        interval_contour = [0 100 200 500 1000 4000 5000];
    case 'Taiwan'
        interval_contour = [0:10:150];
    case 'ECS2'
        interval_contour = [0:50:200];
    case 'KS'
        interval_contour = [0:50:200];
    case 'southern'
        interval_contour = [0:20:200];
    case 'Tsugaru'
        interval_contour = [0:100:500];
    case 'Soya'
        interval_contour = [0:50:300];
    case 'YECS_flt'
        interval_contour = [0 50 80 90 100];
end

[lon_lim, lat_lim] = domain_J(domain_case);

%==========================================================================
g = grd(grid_case);

figure; hold on
pcolor(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho); shading flat
[cs, h] = contour(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho, interval_contour, 'k');
clabel(cs, h);
xlim(lon_lim); ylim(lat_lim)
caxis([interval_contour(1) interval_contour(end)])
c = colorbar; c.Label.String = 'Depth(m)'; c.FontSize = 15;
title('Model bathymetry', 'FontSize', 25)

plot(127.7103,34.2936, '.r', 'MarkerSize', 15);
%plot(128.419027,34.222472, '.r', 'MarkerSize', 15);

saveas(gcf, [domain_case, '_', grid_case, '.png'])

%==========================================================================
asdf
filepath_etopo = 'D:\Data\Ocean\Bathymetry\ETOPO1_Bed_g_gmt4.grd\';
filename_etopo = 'ETOPO1_Bed_g_gmt4.grd';
file_etopo = [filepath_etopo, filename_etopo];
ncload(file_etopo)
[lon_ind, lat_ind] = find_ll(x, y, lon_lim, lat_lim);
z = -z; z(z<0) = nan;

figure; hold on
pcolor(x(lon_ind),y(lat_ind),z(lat_ind,lon_ind)); shading flat
[cs, h] = contour(x(lon_ind), y(lat_ind), z(lat_ind,lon_ind), interval_contour, 'k');
clabel(cs, h);
caxis([interval_contour(1) interval_contour(end)])
c = colorbar; c.Label.String = 'Depth(m)'; c.FontSize = 15;
title('ETOPO1 bathymetry', 'FontSize', 25)

%==========================================================================
asdf
% Bathymetry file
zfile = load('D:\Data\Ocean\Bathymetry\30s\KorBathy30s.mat');
Zlon = zfile.xbathy; Zlat = zfile.ybathy; Zz = zfile.zbathy;

zind = find(lon_lim(1) < Zlon & Zlon < lon_lim(2) & lat_lim(1) < Zlat & Zlat < lat_lim(2));

figure; hold on
scatter(Zlon,Zlat, 8, Zz); shading flat
caxis([interval_contour(1) interval_contour(end)])
c = colorbar; c.Label.String = 'Depth(m)'; c.FontSize = 15;
xlim(lon_lim); ylim(lat_lim)
title('KorBathy 30s bathymetry', 'FontSize', 25)

%==========================================================================
asdf
% Bathymetry file
filepath_etopo = 'D:\Data\Ocean\Bathymetry\ETOPO2v2g\';
filename_etopo = 'ETOPO2v2g_f4.nc';
file_etopo = [filepath_etopo, filename_etopo];
ncload(file_etopo)
[lon_ind, lat_ind] = find_ll(x, y, lon_lim, lat_lim);
z = -z; z(z<0) = nan;

figure; hold on
pcolor(x(lon_ind),y(lat_ind),z(lat_ind,lon_ind)); shading flat
[cs, h] = contour(x(lon_ind), y(lat_ind), z(lat_ind,lon_ind), interval_contour, 'k');
clabel(cs, h);
caxis([interval_contour(1) interval_contour(end)])
c = colorbar; c.Label.String = 'Depth(m)'; c.FontSize = 15;
title('ETOPO2 bathymetry', 'FontSize', 25)