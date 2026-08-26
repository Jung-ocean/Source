clear; clc; close all

yyyy = 2013:2013;
mm = [1:2];

filepath = 'G:\Model\ROMS\Case\NWP\output\exp_SODA3\2013\forcing\';
filename = 'airT_daily_YSBCW.mat';
file = [filepath, filename];
load(file);

xdatevec = datevec(xdate);
xmonth = xdatevec(:,2);
xday = xdatevec(:,3);

airT_target = mean(mean(t2m_all,2),3);
airT_target = airT_target - 273.15;

airT_mean = [];
airT_std = [];
for mi = mm(1):mm(end)
    len_day = eomday(1,mi);
    for di = 1:len_day
        index = find(xmonth == mi & xday == di);
        airT_mean = [airT_mean; mean(airT_target(index))];
        airT_std = [airT_std; std(airT_target(index))];
    end
end

xdatenum = datenum(1,mm(1),1):datenum(1,mm(end),eomday(1,mm(end)));

for i = 1:length(yyyy)
    
    tys = num2str(yyyy(i));
    
    len_data = length(xdatenum);
    
    figure; hold on
    upart = [airT_mean + airT_std]';
    dpart = [airT_mean - airT_std]';
    
    h = fill([xdatenum, fliplr(xdatenum)], [upart, fliplr(dpart)], [.9 .9 .9]);
    h.LineStyle = 'none';
    h_mean = plot(xdatenum, airT_mean, 'LineWidth', 1, 'Color', [.5 .5 .5]);
    
    h_2013 = plot(xdatenum, airT_target(len_data*34-(len_data-1):len_data*34), 'LineWidth', 2, 'Color', [0.4706 0.6706 0.1882]);
    
    %h_target = plot(xdatenum, airT_target(len_data*i-(len_data-1):len_data*i), 'LineWidth', 2, 'Color', [0.9294 0.6902 0.1294]);
    
    ylim([-15 15])
    datetick('x', 'mm')
    xlim([datenum(1, mm(1), 1)-1 datenum(1, mm(end)+1, 1)])
    xlabel('Month'); ylabel('Air temperature (deg C)');
    set(gca, 'FontSize', 15)
    
    l = legend([h_mean h_2013], 'mean (1980-2015)', tys);
    l.FontSize = 15;
    l.Location = 'NorthEast';
    
    title([tys, ' Air temperature ', ...
    num2str(lat_lim(1)), '-', num2str(lat_lim(2)), '\circN ', ...
    num2str(lon_lim(1)), '-', num2str(lon_lim(2)), '\circE'], 'FontSize', 18)
    df
    saveas(gcf, [tys, '.png'])
    
end