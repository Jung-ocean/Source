%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save ROMS streamfunction monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
yyyy_all = 2019:2022;
mm_all = 1:8;

% Load grid information
g = grd('BSf');
dx = 1./g.pm;
dy = 1./g.pn;

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        filename = [exp, '_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        zeta = ncread(file, 'zeta')';
        u = ncread(file, 'u');
        u = permute(u, [3 2 1]);
        v = ncread(file, 'v');
        v = permute(v, [3 2 1]);

        z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
        dz= z_w(2:end,:,:) - z_w(1:end-1,:,:);
        dzu = 0.5*(dz(:,:,1:end-1)+dz(:,:,2:end));
        dzv = 0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));

        hu = squeeze(sum(dzu.*u, 1));
        hv = squeeze(sum(dzv.*v, 1));

        hu(g.mask_u == 0) = 0;
        hv(g.mask_v == 0) = 0;

        psi = get_psi(hu,hv,g.pm,g.pn,g.mask_rho);
        psi_rho = psi2rho(psi);

        save(['psi_', ystr, mstr, '.mat'], 'psi_rho')
        disp([ystr, mstr, '...'])
    end
end

% figure; hold on
% plot_map('Bering', 'mercator', 'l')
% pcolorm(g.lat_rho, g.lon_rho, psi_rho.*g.mask_rho./g.mask_rho/1e6);
% caxis([0 10])
% contourm(g.lat_rho, g.lon_rho, psi_rho.*g.mask_rho/1e6, [0:.2:10], 'k');
