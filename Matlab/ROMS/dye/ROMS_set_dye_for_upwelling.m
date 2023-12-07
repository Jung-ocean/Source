clear; clc; close all

g = grd('upwelling1km_flat');

filename_dye = ['roms_ini_upwelling_ideal_1km_flat_21_a5_10days_dye.nc'];
nc = netcdf(filename_dye, 'w');

dye_01 = nc{'dye_01'}(:); dye_01 = dye_01.*0;
%dye_02 = nc{'dye_02'}(:); dye_02 = dye_01.*0;
%dye_03 = nc{'dye_03'}(:); dye_03(dye_03 > 100) = 0;

nc_cri = netcdf(filename_dye);
% temp = nc_cri{'temp'}(:);
% salt = nc_cri{'salt'}(:);
zeta = nc_cri{'zeta'}(:);
depth = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w', 2);

index = find(depth(:,180,350) < -40);
dye_01(index,:,:) = 100;

% 
% temp = temp(:);
% salt = salt(:);
% depth = depth(:);
% 
% index01 = find(depth > -100 & temp <= 10);
% %index02 = find(depth <= -100 & temp <= 12 & salt >= 34);
% %index03 = find(depth < -100 & temp < 12);
% 
% dye_01(index01) = 100;
% %dye_02(index02) = 1000;
% %dye_03(index03) = 1000;
% 
% dye_01(:,:,160:end) = 0; % 160:end means east southern coast of Korean peninsula ~ East Sea
% %dye_02(:,:,160:end) = 0;

nc{'dye_01'}(:) = dye_01;
%nc{'dye_02'}(:) = dye_02;
%nc{'dye_03'}(:) = dye_03;

close(nc)