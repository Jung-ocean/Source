clear; clc

filepath = 'G:\Model\ROMS\Case\NWP\input\';

% onshore
% lon_lim = [120 130];
% lat_lim = [25 35];

% YSBCW
% lon_lim = [117 127];
% lat_lim = [30 42];

% Southern coast upwelling
lon_lim = [126 129];
lat_lim = [33.5 35];

varis = {'U', 'V'}; % variables

U_all = [];
V_all = [];
for yi = 2013:2013
    tys = num2str(yi)
    
    for vi = 1:length(varis)
        vari_name = varis{vi};
        filename = [vari_name, 'wind_NWP_ECMWF_', tys, '.nc'];
        file = [filepath, filename];
        nc = netcdf(file);
        lon_rho = nc{'lon_rho'}(:); lat_rho = nc{'lat_rho'}(:);
        [lon_ind, lat_ind] = find_ll(lon_rho, lat_rho, lon_lim, lat_lim);
        vari = nc{[vari_name, 'wind']}(:,lat_ind, lon_ind);
        close(nc)
        for mi = 1:12
            day_average(mi) = eomday(yi, mi);
            vari_monthly(mi,:,:) = squeeze(mean(vari(1:day_average(mi)*4,:,:)));
            vari(1:day_average(mi)*4,:,:) = [];
        end
        eval([vari_name, '_all = [', vari_name, '_all; vari_monthly];'])
        clearvars vari_monthly
    end
end

%U = cos(-pi/4)*U - sin(-pi/4)*V; % 축을 45도로 회전 = U, V를 -45도로 회전
%V = sin(-pi/4)*U + cos(-pi/4)*V;

r = sqrt(U_all.*U_all + V_all.*V_all);
theta = atan2(V_all,U_all);

U_CC45 = r.*cos(theta - pi/4); % CC = counter clockwise
V_CC45 = r.*sin(theta - pi/4);

tau = stresslp(r,10); % wind stress scalar

tau_NE = tau./r.*(-U_CC45); % 45도 회전해서 남서풍이기 때문에 북동풍을 구하기 위한 negative
tau_NE_spatial_mean = mean(mean(tau_NE,2),3);

tau_NW = tau./r.*(-V_CC45);
tau_NW_spatial_mean = mean(mean(tau_NW,2),3);

tau_W = tau./r.*U_all;
tau_W_spatial_mean = mean(mean(tau_W,2),3);

tau_S = tau./r.*V_all;
tau_S_spatial_mean = mean(mean(tau_S,2),3);

xdate = [];
for yi = 2001:2015
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

figure; hold on; grid on
plot(xdatenum, tau_NE_spatial_mean, 'LineWidth', 2)
plot(xdatenum, tau_NW_spatial_mean, 'LineWidth', 2)
datetick('x', 'yyyy')
xlim([datenum(2000, 12, 31), datenum(2016, 1, 1)])
xlabel('Year'); ylabel('wind stress (N/m^2)');
set(gca, 'FontSize', 20)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [2001:2015])
h = legend('Northeasterly', 'Northwesterly', 'Location', 'NorthWest');
h.FontSize = 25;
title('Monthly mean wind stress 25-35\circN, 120-130\circE', 'FontSize', 20)