clear; clc

load ..\forcing\point.mat; distance_coastal = 10; % ~ 100km

density_ref = 1024;

yyyy = [2013:2013];
filenum_all = 182:243;

gd = grd('EYECS_20190904');

for fi = 1:length(filenum_all)
    filenum = num2char(filenum_all(fi),4)
    
    nc = netcdf(['avg_', filenum, '.nc']);
    w = nc{'w'}(:);
    zeta = nc{'zeta'}(:);
    temp = nc{'temp'}(:);
    salt = nc{'salt'}(:);
    close(nc)
    
    zeta(abs(zeta) > 100) = NaN;
    temp(abs(temp) > 100) = NaN;
    salt(abs(salt) > 100) = NaN;
    salt(salt < 0) = 0;
    w(abs(w) > 100) = NaN;
    
    depth = zlevs(gd.h,zeta,gd.theta_s,gd.theta_b,gd.hc,gd.N,'rho', 2);
    
    pdens = zeros(size(depth));
    for si = 1:gd.N
        pres = sw_pres(squeeze(depth(si,:,:)), gd.lat_rho);
        pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
    end
    
    for li = 1:length(x)
        density_tmp = pdens(:,y:-1:y-(distance_coastal),x(li));
        w_tmp = w(:,y:-1:y-(distance_coastal),x(li));
        
        density_dist = abs(density_tmp(:,5) - density_ref);
        index = find(density_dist == min(density_dist));
        
        w_1024 = w_tmp(index,6);
        
        wt(fi,li,:) = w_1024*60*60*24;
    end
    
end

xdate = [182:243]+1;

figure; grid on; hold on
plot(xdate, mean(wt,2));
