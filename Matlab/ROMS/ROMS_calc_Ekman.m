clear; clc; close all

yyyy = 1980:2015;
mm = 7:8; %mts = num2char(mm,2);
%
load point.mat
lat_ind = y;
lon_ind = x;
%
g = grd('NWP');
dx = 1./g.pm;

% for i = 1:length(lon_ind);
%     dx_coast(i) = dx(lat_ind(i), lon_ind(i));
% end
% 
% %
% figure; p = pcolor(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho);
% for li = 1:length(lat_ind)
%     p.CData(lat_ind(li), lon_ind(li)) = 5000;
% end
% xlim([125.5 129.5]); ylim([33.8 35.8])
% 
% saveas(gcf, 'Ekman.png')
% 
% % degree
% degree = atan((g.lat_rho(198,123) - g.lat_rho(193,105)) / (g.lon_rho(198,123) - g.lon_rho(193,105)))*180/pi
% vec = [g.lon_rho(198,123) - g.lon_rho(193,105), g.lat_rho(198,123) - g.lat_rho(193,105)];
% unit_vec = vec/sqrt(sum(vec.*vec));
% 
% for yi = 1:length(yyyy)
%     yts = num2str(yyyy(yi))
%     
%     unc = netcdf(['G:\Model\ROMS\Case\NWP\input\Uwind_NWP_ECMWF_', yts, '.nc']);
%     vnc = netcdf(['G:\Model\ROMS\Case\NWP\input\Vwind_NWP_ECMWF_', yts, '.nc']);
%     ot = unc{'Uwind_time'}(:);
%     date_vec = datevec(ot + datenum(yyyy(yi),1,1));
%     
%     tindex = [];
%     for mi = 1:length(mm)
%         tindex = [tindex; find(date_vec(:,2) == mm(mi))];
%     end
%     
%     wind_time = datenum(1,date_vec(tindex,2),date_vec(tindex,3), date_vec(tindex,4), 0, 0);
%     
%     uwind = [];
%     vwind = [];
%     for li = 1:length(lat_ind)
%         u_tmp = squeeze((unc{'Uwind'}(tindex, lat_ind(li), lon_ind(li))));
%         v_tmp = squeeze((vnc{'Vwind'}(tindex, lat_ind(li), lon_ind(li))));
%         
%         uwind = [uwind, u_tmp];
%         vwind = [vwind, v_tmp];
%     end
%     
%     r = sqrt(uwind.*uwind + vwind.*vwind);
%     theta = atan2(vwind,uwind);
%     
%     tau = stresslp(r,10); % wind stress scalar
%     
%     tau_x = tau./r.*uwind;
%     tau_y = tau./r.*vwind;
%     
%     rho = 1027;
%     f = 10^-4;
%     rhof = rho.*f;
%     
%     for ti = 1:length(tau_x)
%         windstress = [tau_x(ti,:)' tau_y(ti,:)'];
%         dotprod = windstress*unit_vec';
%         
%         Ekman(yi,ti,:) = (dotprod.*dx_coast'/rhof);
%     end
% end

load Ekman.mat

Ekman_southern = squeeze(sum(Ekman,3));

Ekman_mean = mean(Ekman_southern)';
Ekman_std = std(Ekman_southern)';

upart = [Ekman_mean + Ekman_std];
dpart = [Ekman_mean - Ekman_std];

figure; hold on;

h = fill([wind_time', fliplr(wind_time')], [upart', fliplr(dpart')], [.9 .9 .9]);
h.LineStyle = 'none';
h_mean = plot(wind_time, Ekman_mean, 'LineWidth', 1, 'Color', [.5 .5 .5]);
h_2013 = plot(wind_time, Ekman_southern(34,:), 'Color', [0 0.4510 0.7412], 'linewidth', 2);

xticks([wind_time(1:8*10:end)])
datetick('x', 'mmdd', 'keepticks')
xlabel('Date'); ylabel('Transport (m^3/s)')
set(gca, 'FontSize', 15)

l = legend([h_mean h_2013], 'Mean (1980-2015)', '2013');
l.FontSize = 15;
l.Location = 'NorthEast';

saveas(gcf, 'Ekman_transport_3h.png')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ekman_sum = sum(Ekman_southern, 2);
figure; hold on; grid on
plot(1980:2015, Ekman_sum, '-o', 'linewidth', 2)
xlabel('Year'); ylabel('Transport (m^3/s)')
set(gca, 'FontSize', 15)
xlim([1980 2015]);
saveas(gcf, 'Ekman_sum.png')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vari_all = [];
for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target)
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
    if year_target == 1980
        filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
    end
    
    for mi = 1:length(mm)
        month_target = mm(mi); mts = num2char(month_target, 2);
        filename = ['monthly_', yts, mts, '.nc'];
        file = [filepath, filename];
        vari = get_hslice_J(file,g,'temp',-1,'r');
        
        vari_coastal = [];
        for li = 1:length(lat_ind)
            vari_coastal = [vari_coastal; vari(lat_ind(li), lon_ind(li))];
        end
        
        if yi == 34
            vari_coastal_2013 = vari_coastal;
        end
        
        vari_all(yi,:) = nanmean(vari_coastal);
    end
end

figure; hold on; grid on
h = plot(vari_coastal_2013, 'linewidth', 2);

xlabel('Point')
ylabel('Temperature (deg C)')

Ekman_2013 = squeeze(sum(Ekman(34,:,:),2));
yyaxis right
plot(Ekman_2013, 'linewidth', 2);
ylabel('Ekman transport (m^3/s)')

h = get(gca);
h.YAxis(1).Color = [0 0.4510 0.7412];
set(gca, 'FontSize', 15)
saveas(gcf, 'along_coast_07.png')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure; hold on
plot(Ekman_sum, vari_all, 'ko')

index = find(yyyy == 2013);
plot(Ekman_sum(index), vari_all(index), 'ro', 'MarkerFaceColor', 'r')

xlabel('Ekman transport (m^3/s)')
ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)

[p,s] = polyfit(Ekman_sum, vari_all, 1);
Ekman_sum2 = min(Ekman_sum):0.1:max(Ekman_sum);

y1 = polyval(p,Ekman_sum2);
h1 = plot(Ekman_sum2, y1, '--k', 'LineWidth', 2);

corr(vari_all, Ekman_sum)

ylim([20 30])
xlim([-2000 2000])

title(['Correlation = ', num2str(corr(vari_all, Ekman_sum))], 'FontSize', 15)
saveas(gcf, 'Ekman_corr.png')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load openocean.mat
lat_ind = y;
lon_ind = x;

g = grd('NWP');

%
figure; p = pcolor(g.lon_rho, g.lat_rho, g.h.*g.mask_rho./g.mask_rho);
for li = 1:length(lat_ind)
    p.CData(lat_ind(li):-1:lat_ind(li)-9, lon_ind(li)) = 5000;
end
xlim([126 130]); ylim([32 35])

saveas(gcf, 'openocean.png')

vari_open_all = [];
for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target)
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
    if year_target == 1980
        filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
    end
    
    for mi = 1:length(mm)
        month_target = mm(mi); mts = num2char(month_target, 2);
        filename = ['monthly_', yts, mts, '.nc'];
        file = [filepath, filename];
        vari = get_hslice_J(file,g,'temp',-1,'r');
        
        vari_openocean = [];
        for li = 1:length(lat_ind)
            vari_openocean = [vari_openocean vari(lat_ind(li):-1:lat_ind(li)-9, lon_ind(li))];
        end
        
        if yi == 34
            vari_openocean_2013 = vari_openocean;
        end
        
        vari_open_all(yi,:) = nanmean(nanmean(vari_openocean));
    end
end

figure; hold on; grid on
plot(1980:2015, vari_open_all, '-o', 'linewidth', 2)
xlabel('Year'); ylabel('Temperature (deg C)')
set(gca, 'FontSize', 15)
xlim([1980 2015]);
saveas(gcf, 'openocean_temp.png')

%%%%%%%
vari_diff = vari_all - vari_open_all;

figure; hold on; grid on
plot(1980:2015, vari_diff, '-o', 'linewidth', 2)
xlabel('Year'); ylabel('Temperature difference (deg C)')
set(gca, 'FontSize', 15)
xlim([1980 2015]);
saveas(gcf, 'openocean_temp_diff.png')
%%%%
figure; hold on
plot(Ekman_sum, vari_diff, 'ko')

index = find(yyyy == 2013);
plot(Ekman_sum(index), vari_diff(index), 'ro', 'MarkerFaceColor', 'r')

xlabel('Ekman transport (m^3/s)')
ylabel('Temperature difference(deg C)')
set(gca, 'FontSize', 15)

[p,s] = polyfit(Ekman_sum, vari_diff, 1);
Ekman_sum2 = min(Ekman_sum):0.1:max(Ekman_sum);

y1 = polyval(p,Ekman_sum2);
h1 = plot(Ekman_sum2, y1, '--k', 'LineWidth', 2);

corr(vari_diff, Ekman_sum)

ylim([-10 2])
xlim([-2000 2000])

title(['Correlation = ', num2str(corr(vari_diff, Ekman_sum))], 'FontSize', 15)
saveas(gcf, 'Ekman_corr_diff.png')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
velocity_all = [];
[lon_lim, lat_lim] = domain_J('current_southern');
[lon_ind, lat_ind] = find_ll(g.lon_rho, g.lat_rho, lon_lim, lat_lim);

for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target)
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\', yts, '\'];
    if year_target == 1980
        filepath = ['G:\Model\ROMS\Case\NWP\output\exp_SODA3\old_1980\1980_ver38\output_14\'];
    end
    
    for mi = 1:length(mm)
        month_target = mm(mi); mts = num2char(month_target, 2);
        filename = ['monthly_', yts, mts, '.nc'];
        file = [filepath, filename];
        %vari = get_hslice_J(file,g,'u',-1,'u');
        nc = netcdf(file);
        vari = nc{'u'}(:, :, lat_ind, lon_ind);
        close(nc);
        
        %vari_vel = vari(lat_ind, lon_ind);
        
        vari(vari > 1000) = NaN;
        zindex = find(g.z_r(:,lat_ind, lon_ind) > -1);
        vari_vel = nanmean(vari(zindex));
        
        if yi == 34
            vari_vel = vari_vel;
        end
        
        velocity_all(yi,:) = nanmean(nanmean(vari_vel));
    end
end
%%%
figure; map_J('KODC_small')
plot_line_map(lon_lim, lat_lim, 'k', '-')
saveas(gcf, 'velocity_southern_area.png')
%%%
figure; hold on; grid on
plot(1980:2015, velocity_all, '-o', 'linewidth', 2)
xlabel('Year'); ylabel('Velocity (m/s)')
set(gca, 'FontSize', 15)
xlim([1980 2015]);
saveas(gcf, 'velocity_southern.png')
%%%
figure; hold on
plot(velocity_all, vari_diff, 'ko')

index = find(yyyy == 2013);
plot(velocity_all(index), vari_diff(index), 'ro', 'MarkerFaceColor', 'r')

xlabel('Velocity (m/s)')
ylabel('Temperature difference(deg C)')
set(gca, 'FontSize', 15)

[p,s] = polyfit(velocity_all, vari_diff, 1);
velocity_all2 = min(velocity_all):0.01:max(velocity_all);

y1 = polyval(p,velocity_all2);
h1 = plot(velocity_all2, y1, '--k', 'LineWidth', 2);

corr(vari_diff, velocity_all)

ylim([-10 2])
xlim([0 0.7])

title(['Correlation = ', num2str(corr(vari_diff, velocity_all))], 'FontSize', 15)

saveas(gcf, 'velocity_corr_diff.png')