clear; clc

roms_matlab = '/home/server/pi/homes/jungjih/Source/Matlab/ROMS/roms_matlab';
addpath(genpath(roms_matlab));

filename = 'grid_Oregon_1km_sponge.nc';
G = get_roms_grid(filename);

wtype_grid = 4.*ones(size(G.lon_rho));

% Plot
figure;
% contourf(G.lon_rho, G.lat_rho, nanland(S.diff_factor,G));
pcolorjw(G.lon_rho, G.lat_rho, wtype_grid.*G.mask_rho./G.mask_rho);
title('Jerlov water type index')
colorbar;
set(gcf, 'Position', [1 200 500 800])

print('wtype', '-dpng')

% Write
try
    nccreate(filename, 'wtype_grid', 'Dimensions',{'xi_rho', 'eta_rho'})
    ncwriteatt(filename, 'wtype_grid', 'long_name', "Jerlov water type index")
    ncwriteatt(filename, 'wtype_grid', 'coordinates', "lon_rho lat_rho")
    ncwrite(filename, 'wtype_grid', wtype_grid);
catch
    ncwrite(filename, 'wtype_grid', wtype_grid);
end

wtype_info = [datestr(now,1) ' created with ' which(mfilename)];
status = nc_attadd(filename, 'wtype_grid', wtype_info);

rmpath(genpath(roms_matlab));