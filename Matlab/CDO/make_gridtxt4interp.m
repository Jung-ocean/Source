clear; clc

grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);

len_lat = size(g.lat_rho, 1);
len_lon = size(g.lon_rho, 2);
len_gridsize = length(lat)*length(lon);

format_string = '%s\n';

fileID = fopen('ROMSgrid.txt', 'w');
fprintf(fileID, format_string, 'gridtype = curvilinear');
fprintf(fileID, format_string, ['gridsize  = ', num2str(len_gridsize)]);
fprintf(fileID, format_string, ['xsize  = ', num2str(len_lon)]);
fprintf(fileID, format_string, ['ysize  = ', num2str(len_lat)]);
fprintf(fileID, format_string, 'xname     = longitude')
fprintf(fileID, format_string, 'xdimname  = xgrid')
fprintf(fileID, format_string, 'xlongname = "longitude"')
fprintf(fileID, format_string, 'xunits    = "degrees_east"')
fprintf(fileID, format_string, 'yname     = latitude')
fprintf(fileID, format_string, 'ydimname  = ygrid')
fprintf(fileID, format_string, 'ylongname = "latitude" ')
fprintf(fileID, format_string, 'yunits    = "degrees_north" ')
fprintf(fileID, format_string, 'xvals    = ')
for xi = 1:size(g.lat_rho, 1)
    fprintf(fileID, format_string, num2str(g.lon_rho(xi,:)))
    if xi == size(g.lat_rho, 1)
        fprintf(fileID, '\n')
    end
end
fprintf(fileID, format_string, 'yvals    = ')
for yi = 1:size(g.lat_rho, 1)
    fprintf(fileID, format_string, num2str(g.lat_rho(yi,:)))
    if xi == size(g.lat_rho, 1)
        fprintf(fileID, '\n')
    end
end
fclose(fileID)