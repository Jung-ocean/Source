clear; clc; close all

year_all = [1980:2015];
month_all = [1 2];
[lon_lim, lat_lim] = domain_J('airT_YSBCW');
varis = {'t2m'}; % variables
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
        
        index_time = find(date_vari_vec(:,2) == 1 | date_vari_vec(:,2) == 2);
        if leapyear(yyyy)
            index_time(end) = [];
        end
        
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
clearvars -except t2m_all xdate lon_lim lat_lim

t2m_spatial_mean = mean(mean(t2m_all,2),3) - 273.15;

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
title(['Air temperature ', ...
    num2str(lat_lim(1)), '-', num2str(lat_lim(2)), '\circN ', ...
    num2str(lon_lim(1)), '-', num2str(lon_lim(2)), '\circE'], 'FontSize', 18)