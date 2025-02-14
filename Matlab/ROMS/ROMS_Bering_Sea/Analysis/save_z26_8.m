%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save z26.8 using ROMS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

lat_target = 60;
sigma_theta_target = 26.8;

exp = 'Dsm4';
g = grd('BSf');
h = g.h;
lat = g.lat_rho;
lon = g.lon_rho;
mask = g.mask_rho./g.mask_rho;

startdate = datenum(2018,7,1);
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

latdist = abs(lat(:,1) - lat_target);
latind = find(latdist == min(latdist));

figure; hold on;
plot_map('Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');
lat_map = lat.*mask;
lon_map = lon.*mask;
plotm(lat_map(latind, :), lon_map(latind, :), '.r');
print(['map_lat_', num2str(lat_target)], '-dpng')

timenum_start = datenum(2019,1,1);
timenum_end = datenum(2022,12,31);

filenum_start = timenum_start - startdate + 1;
filenum_end = timenum_end - startdate + 1;
filenum_all = filenum_start:filenum_end;

timenum = NaN(length(filenum_all),1);
z26_8 = NaN([length(filenum_all), size(g.lon_rho, 2)]);
for fi = 1:length(filenum_all)

    filenum = filenum_all(fi);
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];

    if exist(file)

        ot = ncread(file, 'ocean_time');
        timenum(fi) = ot/60/60/24 + datenum(1968,5,23);
        zeta = ncread(file, 'zeta', [1 latind 1], [Inf 1 Inf]);
        depth = zlevs(h(latind,:)',zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2)';

        temp = squeeze(ncread(file, 'temp', [1 latind 1 1], [Inf 1 Inf Inf]));
        salt = squeeze(ncread(file, 'salt', [1 latind 1 1], [Inf 1 Inf Inf]));

        pres = sw_pres(abs(depth), lat(latind,:)');
        pden = sw_pden_ROMS(salt, temp, pres, 0);
        sigma_theta = pden - 1000;

        for si = 1:size(sigma_theta,1)
            depth_tmp = abs(depth(si,:));
            sigma_tmp = sigma_theta(si,:);

            if isnan(sum(sigma_tmp)) == 1 | max(sigma_tmp) < sigma_theta_target | min(sigma_tmp) > sigma_theta_target
                z26_8(fi,si) = NaN;
            else
                dist = abs(sigma_tmp - sigma_theta_target);
                index = find(dist == min(dist));
                
                try
                    z_tmp = interp1(sigma_tmp(index-1:index+1), depth_tmp(index-1:index+1), sigma_theta_target);
                catch
                    z_tmp = interp1(sigma_tmp(index:index+1), depth_tmp(index:index+1), sigma_theta_target);
                end
                    z26_8(fi,si) = z_tmp;
            end
        end

    else
        timenum(fi) = NaN;
        z26_8(fi,:) = NaN;
    end

    disp(filename)
end % fi

lon_target = lon(latind,:)';

figure;
pcolor(lon_target, timenum, z26_8);
shading flat

save(['z26_8_lat_', num2str(lat_target), '.mat'], 'z26_8', 'timenum', 'lon_target')