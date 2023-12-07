clear; clc

filename_wind = 'wind_daily_southern.mat';
xlabel_wind = 'Westerly';
vari_wind = 'u10_all';

yyyy = 1980:2015;
mm = 8:8;

g = grd('NWP');
lon = g.lon_rho;
lat = g.lat_rho;

[lon_lim, lat_lim] = domain_J('current_southern');

[lon_ind, lat_ind] = find_ll(lon, lat, lon_lim, lat_lim);
%zindex = find(g.z_r(:,lat_ind, lon_ind) > -10);

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
    nc = netcdf(file);
    %vari = nc{'temp'}(1,:,lat_ind, lon_ind);
    close(nc)
    
    vari = get_hslice_J(file,g,'u',-1,'u');
        
    %vari(vari > 1000) = NaN;
    
    %vari_all = [vari_all; nanmean(vari(zindex))];
    vari_all = [vari_all; nanmean(nanmean(vari(lat_ind, lon_ind)))];
    end
end
    
load(['G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\forcing\', filename_wind])
datevec_wind = datevec(xdate);
year_wind = datevec_wind(:,1);
month_wind = datevec_wind(:,2);
wind = eval(vari_wind);

wind_all = [];
for yi = 1:length(yyyy)
    year_target = yyyy(yi);
    for mi = 1:length(mm)
        month_target = mm(mi);
    index = find(year_wind == year_target & month_wind == month_target);
    
    wind_all = [wind_all; mean(mean(mean(wind(index,:,:))))];
    end
end

figure; hold on
plot(wind_all, vari_all, 'ko')

index = find(yyyy == 2013);
plot(wind_all(index), vari_all(index), 'ro', 'MarkerFaceColor', 'r')

xlabel([xlabel_wind, ' (m/s)'])
ylabel('Zonal velocity (m/s)')
set(gca, 'FontSize', 15)

[p,s] = polyfit(wind_all, vari_all, 1);
wind_all2 = min(wind_all):0.1:max(wind_all);

y1 = polyval(p,wind_all2);
h1 = plot(wind_all2, y1, '--k', 'LineWidth', 2);

corr(vari_all, wind_all)

title(['Correlation = ', num2str(corr(vari_all, wind_all))], 'FontSize', 15)