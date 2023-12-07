clear; clc

%lon_lim = [124.8 126.0]; lat_lim = [33.8 35]; % 남서해안
%lon_lim = [125.113 125.178]; lat_lim = [33.95 34.15]; % 가거도
%lon_lim = [125.45 125.55]; lat_lim = [34.1 34.25]; % 만재도
lon_lim = [126 128.5]; lat_lim = [33.5 35]; % 남해

g = grd('EYECS_20220110');
%copyfile(g.grd_file,'test.nc')

xv = [lon_lim(1) lon_lim(1) lon_lim(2) lon_lim(2) lon_lim(1)];
yv = [lat_lim(1) lat_lim(2) lat_lim(2) lat_lim(1) lat_lim(1)];

mask = inpolygon(g.lon_rho, g.lat_rho, xv, yv);
[mi,mj] = size(mask);

figure; pcolor(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho.*mask./mask); shading flat

tnc = netcdf(g.grd_file, 'w');
h = tnc{'h'}(:);
h_new = h;

filepath_etopo = 'D:\Data\Ocean\Bathymetry\ETOPO1_Bed_g_gmt4.grd\';
filename_etopo = 'ETOPO1_Bed_g_gmt4.grd';
file_etopo = [filepath_etopo, filename_etopo];
ncload(file_etopo)
z = -z; z(z<0) = 0;

h_new_ETOPO1 = interp2(x,y,z,g.lon_rho,g.lat_rho,'cubic');

for i = 1:mi
    for j = 1:mj
        if mask(i,j) == 1
            h_new(i,j) = h_new_ETOPO1(i,j);
             if h_new_ETOPO1(i,j) < 20
                h_new(i,j) = h_new_ETOPO1(i,j)-5;
             end
        end
    end
end
h_new(h_new < 7) = 7;

h_new_smooth = smoothgrid(h_new, g.mask_rho, 7, 10, 5000, 0.8, 3 ,2);
%h_new_smooth = smoothgrid(h_new, g.mask_rho, 7, 100, 5000, 0.6, 3 ,3);
%h_new_smooth = smoothgrid(h_new, g.mask_rho, 7, 100, 5000, 0.4, 3 ,12);

for i = 1:mi
    for j = 1:mj
        if mask(i,j) == 1
            h(i,j) = h_new_smooth(i,j);
        end
    end
end

tnc{'h'}(:) = h;
close(tnc)