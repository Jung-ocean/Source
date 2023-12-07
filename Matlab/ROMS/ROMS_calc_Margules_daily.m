clear; clc

f = 10^-4;
g = 10;

%load ..\location_205.mat
load ..\forcing\point.mat; distance_coastal = 10; % ~ 100km

density_ref = 1024;

yyyy = [2013:2013];
filenum_all = 182:243;

gd = grd('EYECS_20190904');

for fi = 1:length(filenum_all)
    filenum = num2char(filenum_all(fi),4)
    
    nc = netcdf(['avg_', filenum, '.nc']);
    zeta = nc{'zeta'}(:);
    temp = nc{'temp'}(:);
    salt = nc{'salt'}(:);
    u = nc{'u'}(:);
    close(nc)
    
    temp(abs(temp) > 100) = NaN;
    salt(abs(salt) > 100) = NaN;
    u(abs(u) > 100) = NaN;
        
    depth = zlevs(gd.h,zeta,gd.theta_s,gd.theta_b,gd.hc,gd.N,'rho', 2);
    
    pdens = zeros(size(depth));
    for si = 1:gd.N
        pres = sw_pres(squeeze(depth(si,:,:)), gd.lat_rho);
        pdens(si,:,:) = sw_pden_ROMS(squeeze(salt(si,:,:)), squeeze(temp(si,:,:)), pres, 0);
    end
    
%     for li = 1:length(lat_line)
%         dist=sqrt((gd.lon_rho-lon_line(li)).^2+(gd.lat_rho-lat_line(li)).^2);
%         min_dist=min(min(dist));
%         [x,y]=find(dist==min_dist);
%         xall(li) = x;
%         yall(li) = y;
%         density_205(:,li) = pdens(:,x,y);
%         u_205(:,li) = u(:,x,y);
%     end
% index_u = find(density_205 < density_ref);
% index_l = find(density_205 > density_ref);
% 
% d1 = mean(density_205(index_u));
% d2 = mean(density_205(index_l));
% 
% u1 = nanmean(u_205(index_u));
% u2 = nanmean(u_205(index_l));

% u1d1_u2d2(fi) = u1*d1 - u2*d2;
% d2_d1(fi) = d2-d1;
% dhdy(fi) = f*(u1d1_u2d2(fi)) / (g*(d2_d1(fi)));
% Margules(fi) = dhdy(fi)*(lat_line(end) - lat_line(1))*111*1000;

for li = 1:length(x)
    density_tmp = pdens(:,y:-1:y-(distance_coastal),x(li));
    u_tmp = u(:,y:-1:y-(distance_coastal),x(li));
    
    index_u = find(density_tmp < density_ref);
    index_l = find(density_tmp > density_ref);
    
    d1 = mean(density_tmp(index_u));
    d2 = mean(density_tmp(index_l));
    
    u1 = nanmean(u_tmp(index_u));
    u2 = nanmean(u_tmp(index_l));
    
    u1d1_u2d2(fi,li,:) = u1*d1 - u2*d2;
    d2_d1(fi,li,:) = d2-d1;
    dhdy(fi,li,:) = f*(u1d1_u2d2(fi,li,:)) / (g*(d2_d1(fi,li,:)));
    %Margules = dhdy*(lat_line(end) - lat_line(1))*111*1000;
end
        
end

%save Margules1024_205_daily u1d1_u2d2 d2_d1 dhdy Margules
save Margules1024_coast_daily u1d1_u2d2 d2_d1 dhdy

xdate = [182:243]+1;
%xdate = [152:273]+1;

figure; set(gcf, 'Position', [26 2 560 993])

num_subplot = 3;
fs = 15;

subplot(num_subplot,1,1); hold on; grid on
plot(xdate, u1d1_u2d2, 'linewidth', 2)
%xticks([xdate(1) xdate(31) xdate(62) xdate(92) xdate(end)])
xticks([xdate(1) xdate(31) xdate(end)])
datetick('x', 'mmdd', 'keepticks')
ylim([0 400])
ylabel('kg/m^2/s')
title('u_1\rho_1 - u_2\rho_2')
set(gca, 'FontSize', fs)

subplot(num_subplot,1,2); hold on; grid on
plot(xdate, d2_d1, 'linewidth', 2)
%xticks([xdate(1) xdate(31) xdate(62) xdate(92) xdate(end)])
xticks([xdate(1) xdate(31) xdate(end)])
datetick('x', 'mmdd', 'keepticks')
ylim([2 4])
ylabel('kg/m^3')
title('\rho_2 - \rho_1')
set(gca, 'FontSize', fs)

subplot(num_subplot,1,3); hold on; grid on
plot(xdate, dhdy, 'linewidth', 2)
xticks([xdate(1) xdate(31) xdate(end)])
datetick('x', 'mmdd', 'keepticks')
ylim([0 1e-3])
ylabel('Nondimensional')
title('\partialh/\partialy')
set(gca, 'FontSize', fs)

%saveas(gcf, 'Margules_daily_3figs.png')

% subplot(4,1,4); hold on; grid on
% plot(xdate, Margules, 'linewidth', 2)
% xticks([xdate(1) xdate(31) xdate(end)])
% datetick('x', 'mmdd', 'keepticks')
% ylim([0 100])
% ylabel('m')
% title('Uplift height')
% set(gca, 'FontSize', fs)
