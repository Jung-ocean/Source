clear; clc; close all

year_all = [1980:2015];
month_all = [6:8];
[lon_lim, lat_lim] = domain_J('windstress_southern');
varis = {'u10', 'v10'}; % variables
filepath = 'D:\Data\Atmosphere\ECMWF_interim\daily\';

xdate = [];
for vi = 1:length(varis)
    vari_name = varis{vi};
    eval([vari_name, '_all = [];'])
    
    for yi = 1:length(year_all)
        yyyy = year_all(yi)
        tys = num2str(yyyy);
        
        date_vari_str = datestr(datenum(yyyy,1,1):1:datenum(yyyy,12,31), 'yyyymmdd');
        date_vari_vec = datevec(datenum(yyyy,1,1):1:datenum(yyyy,12,31));
        
        filename = [vari_name, '_', tys, '_daily.mat'];
        file = [filepath, filename];
        load(file)
        
        [lon_ind, lat_ind] = find_ll(longitude, latitude, lon_lim, lat_lim);
        
        index_time = find(date_vari_vec(:,2) == 6 | date_vari_vec(:,2) == 7 | date_vari_vec(:,2) == 8);
        xdate = [xdate; datenum(date_vari_vec(index_time,:))];
        
        vari_daily = zeros(length(index_time), length(lat_ind), length(lon_ind));
        for ti = 1:length(index_time)
            date_target = date_vari_str(index_time(ti),:);
            vari_daily(ti,:,:) = eval([vari_name, '_', date_target, '(lat_ind, lon_ind);']);
        end
        eval([vari_name, '_all = [', vari_name, '_all; vari_daily];'])
        clearvars(['*', tys,'*'])
    end
end
clearvars -except u10_all v10_all xdate lon_lim lat_lim

%U = cos(-pi/4)*U - sin(-pi/4)*V; % 축을 45도로 회전 = U, V를 -45도로 회전
%V = sin(-pi/4)*U + cos(-pi/4)*V;

r = sqrt(u10_all.*u10_all + v10_all.*v10_all);
theta = atan2(v10_all,u10_all);

u10_CC45 = r.*cos(theta - pi/4); % CC = counter clockwise
v10_CC45 = r.*sin(theta - pi/4);

tau = stresslp(r,10); % wind stress scalar

tau_NE = tau./r.*(-u10_CC45); % 45도 회전해서 남서풍이기 때문에 북동풍을 구하기 위한 negative
tau_NE_spatial_mean = mean(mean(tau_NE,2),3);

tau_NW = tau./r.*(-v10_CC45);
tau_NW_spatial_mean = mean(mean(tau_NW,2),3);

tau_W = tau./r.*u10_all;
tau_W_spatial_mean = mean(mean(tau_W,2),3);

tau_S = tau./r.*v10_all;
tau_S_spatial_mean = mean(mean(tau_S,2),3);

xdate = [];
for yi = year_all(1):year_all(end)
    for mi = 1:12
        xdate = [xdate; yi mi];
    end
end
xdatenum = datenum(xdate(:,1), xdate(:,2), 15, 0 ,0 ,0);

tau_spatial_mean_Jul = tau_S_spatial_mean;
tau_spatial_mean_Aug = tau_S_spatial_mean;

figure; hold on; grid on
plot(xdatenum, tau_spatial_mean_Jul, 'o', 'LineWidth', 2, 'MarkerSize', 15, 'color', [0.8500 0.3250 0.0980])
plot(xdatenum, tau_spatial_mean_Aug, '+', 'LineWidth', 2, 'MarkerSize', 15)%, 'color', [0 0.4470 0.7410]')
datetick('x', 'yy')
xlim([datenum(year_all(1), 12, 31), datenum(year_all(end)+1, 1, 1)])
ylim([-0.01 0.03]) % ylim([-0.02 0.03])
xlabel('Year'); ylabel('wind stress (N/m^2)');
set(gca, 'FontSize', 20)
set(gca, 'Xtick', [xdatenum(1):365:xdatenum(end)])
set(gca, 'XtickLabel', [year_all(1):year_all(end)])
h = legend('July', 'August', 'Location', 'NorthWest');
h.FontSize = 25;

title(['Westerly wind stress ', ...
    num2str(lat_lim(1)), '-', num2str(lat_lim(2)), '\circN ', ...
    num2str(lon_lim(1)), '-', num2str(lon_lim(2)), '\circE'], 'FontSize', 30)

figure; hold on
xdatenum = datenum(xdate);
for i = 1:36
    if i == 34
        h_target = plot(xdatenum, movmean(tau_S_spatial_mean(92*i-91:92*i), 28), 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
    else
        h = plot(xdatenum, movmean(tau_S_spatial_mean(92*i-91:92*i), 28), 'LineWidth', 1, 'Color', [.7 .7 .7]);
    end
end
uistack(h_target, 'top')

datetick('x', 'mm')
xlim([datenum(0, 5, 31) datenum(0, 9, 1)])
xlabel('Month'); ylabel('wind stress (N/m^2)');
set(gca, 'FontSize', 15)

legend([h h_target], '1980-2015', '2013', 'Location', 'SouthWest')
title(['Southerly wind stress ', ...
    num2str(lat_lim(1)), '-', num2str(lat_lim(2)), '\circN ', ...
    num2str(lon_lim(1)), '-', num2str(lon_lim(2)), '\circE'], 'FontSize', 18)
ylim([-0.06 0.06])