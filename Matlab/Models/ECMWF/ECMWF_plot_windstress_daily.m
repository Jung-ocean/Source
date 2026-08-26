clear; clc; close all

yyyy = 1980:2015;
mm = [6:8];

area = 'YSBCW';

filepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\forcing\';
if strcmp(area, 'southern')
    filename = ['wind_daily_', area, '.mat'];
    vari = 'tau_W_spatial_mean';
    titlename = 'Westerly';
    plotcolor = [0.8510 0.3294 0.1020];
elseif strcmp(area, 'YSBCW')
    filename = ['wind_daily_', area, '.mat'];
    vari = 'tau_S_spatial_mean';
    titlename = 'Southerly';
    plotcolor = [0 0.4510 0.7412];
end
file = [filepath, filename];
load(file);

r = sqrt(u10_all.*u10_all + v10_all.*v10_all);
theta = atan2(v10_all,u10_all);

tau = stresslp(r,10); % wind stress scalar

tau_W = tau./r.*u10_all;
tau_W_spatial_mean = mean(mean(tau_W,2),3);

tau_S = tau./r.*v10_all;
tau_S_spatial_mean = mean(mean(tau_S,2),3);

xdatevec = datevec(xdate);
xmonth = xdatevec(:,2);
xday = xdatevec(:,3);

wind_target = eval(vari);

wind_mean = [];
wind_std = [];
for mi = mm(1):mm(end)
    len_day = eomday(1,mi);
    for di = 1:len_day
        index = find(xmonth == mi & xday == di);
        wind_mean = [wind_mean; mean(wind_target(index))];
        wind_std = [wind_std; std(wind_target(index))];
    end
end

xdatenum = datenum(1,mm(1),1):datenum(1,mm(end),eomday(1,mm(end)));

for i = 34:34%length(yyyy)
    
    tys = num2str(yyyy(i));
    
    len_data = length(xdatenum);
    
    figure; hold on
    upart = [wind_mean + wind_std]';
    dpart = [wind_mean - wind_std]';
    
    h = fill([xdatenum, fliplr(xdatenum)], [upart, fliplr(dpart)], [.9 .9 .9]);
    h.LineStyle = 'none';
    h_mean = plot(xdatenum, wind_mean, 'LineWidth', 1, 'Color', [.5 .5 .5]);
    
    %h_2013 = plot(xdatenum, wind_target(len_data*i-(len_data-1):len_data*i), 'LineWidth', 2, 'Color', plotcolor);
    h_target = plot(xdatenum, wind_target(len_data*i-(len_data-1):len_data*i), 'LineWidth', 2, 'Color', plotcolor);
    
    ylim([-0.1 0.1])
    datetick('x', 'mm')
    xlim([datenum(1, mm(2), 1)-1 datenum(1, mm(end)+1, 1)])
    xlabel('Month'); ylabel('Wind stress (N/m^2)');
    set(gca, 'FontSize', 15)
    
    l = legend([h_mean h_target], 'mean (1980-2015)', tys);
    l.FontSize = 15;
    l.Location = 'southwest';
    
    title([tys, ' ', titlename,' wind stress ', ...
    num2str(lat_lim(1)), '-', num2str(lat_lim(2)), '\circN ', ...
    num2str(lon_lim(1)), '-', num2str(lon_lim(2)), '\circE'], 'FontSize', 18)
df
    saveas(gcf, [titlename, '_', tys, '.png'])
    
end