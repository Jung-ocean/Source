% North of latitude 34.5; same xq, and yq = [34.5 34.5 42 42 34.5];
% North of latitude 33

clear; clc; close all

yyyy_all = 2013:2013;

g = grd('EYECS');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    filename_dye = ['roms_ini_dye_', ystr, '_0701.nc'];
    nc = netcdf(filename_dye, 'w');
    dye_01 = nc{'dye_01'}(:); dye_01 = dye_01.*0;
    ot = nc{'ocean_time'}(:);
    temp = nc{'temp'}(:);
    zeta = nc{'zeta'}(:);
    depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'rho', 2);
    
    figure;
    pcolor(g.lon_rho,g.lat_rho, squeeze(temp(40,:,:)).*g.mask_rho./g.mask_rho); shading flat
    figure; hold on;
    pcolor(g.lon_rho,g.lat_rho, squeeze(temp(1,:,:)).*g.mask_rho./g.mask_rho); shading flat
    [cs,h] = contour(g.lon_rho,g.lat_rho, squeeze(temp(1,:,:)).*g.mask_rho./g.mask_rho, [10:2:14], 'k');
    clabel(cs,h)
    
    temp = temp(:);
    depth = depth(:);
    index01 = find(temp <= 12 & depth > -100);
    
    %dye_01(index01) = 100;
    %dye_01(:,:,165:end) = 0;
    
    %===== Area limitation
    xq = [116 126.5 128 116 116];
    yq = [34.5 34.5 42 42 34.5];
    
    in = inpolygon(g.lon_rho, g.lat_rho, xq, yq);
    
         for i = 1:g.N
             dye_01(i,~in) = 0;
             dye_01(i,in) = 100;
         end
    %=====

    ot = ot-43200;
    ot/60/60/24
    
    nc{'dye_01'}(:) = dye_01;
    nc{'ocean_time'}(:) = ot;
    
    close(nc)
    figure;
    pcolor(g.lon_rho,g.lat_rho, squeeze(dye_01(40,:,:)).*g.mask_rho./g.mask_rho); shading flat
    figure;
    pcolor(g.lon_rho,g.lat_rho, squeeze(dye_01(1,:,:)).*g.mask_rho./g.mask_rho); shading flat
    
end