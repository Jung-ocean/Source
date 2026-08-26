clear; clc; %close all

yyyy = 1980:2015;
mm = [1:2];

area = 'airT_YSBCW';
[lon_lim, lat_lim] = domain_J(area);

filepath = 'D:\Data\Atmosphere\ECMWF_interim\monthly\mat\';

for yi = 1:length(yyyy)
    year_target = yyyy(yi); yts = num2str(year_target);
    filename = ['t2m_', yts, '_monthly.mat'];
    file = [filepath, filename];
    load(file);
    
    Tair = zeros;
    for mi = 1:length(mm)
        month_target = mm(mi); mts = num2char(month_target,2);
        eval(['Tair = Tair + t2m_', yts, mts, ';'])
    end
    Tair_mean = Tair/length(mm);
    
    Tair_monthly(yi,:,:) = Tair_mean-273.15;
end

[lon_ind, lat_ind] = find_ll(longitude, latitude, lon_lim, lat_lim);

Tair_monthly_mean = mean(mean(Tair_monthly(:,lat_ind, lon_ind),2),3);

figure; hold on; grid on
plot(yyyy, Tair_monthly_mean, '-o', 'LineWidth', 2, 'color', [0.4706 0.6706 0.1882])
ylabel('Air temperature (deg C)')
xlabel('Year')
set(gca, 'FontSize', 15)
xlim([1980 2015])