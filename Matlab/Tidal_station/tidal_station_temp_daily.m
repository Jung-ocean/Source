%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot tidal station temperature
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

station_list = {'거문도', '거제도', '고흥발포', '여수', '완도', '진도', '추자도', '통영'};
for si = 1:length(station_list)
    station = station_list{si};
    
    % File
    filepath = 'D:\Data\Ocean\조위관측소\TS\';
    filelist = dir([filepath, '*', station, '*']);
    
    figure; hold on; grid on;
    
    xdatenum_all = [];
    temp_daily_all = [];
    for fi = 1:length(filelist)-1
        
        file = [filepath, filelist(fi).name];
        % Read all data as string
        [num, yyyymmdd, hhhh, temp, salt] = textread(file, '%s %s %s %s %s', 'headerlines', 6);
        data1 = [num, yyyymmdd, hhhh, temp, salt];
        
        % Set file date
        yyyymmdd = cell2mat(data1(:,2));
        yyyy = str2num(yyyymmdd(:,1:4));
        yyyy_all(fi) = yyyy(1);
        
        yyyymmdd_str = [yyyymmdd(:,1:4), yyyymmdd(:,6:7), yyyymmdd(:,9:10)];
        yyyymmdd_day = str2num(yyyymmdd_str);
        yyyymmdd_day_unique = unique(yyyymmdd_day);
        yyyymmdd_day_unique_str = num2str(yyyymmdd_day_unique);
        ydus = yyyymmdd_day_unique_str;
        ydus_mm = ydus(:,5:6); ydus_dd = ydus(:,7:8);
        ydu_mm = str2num(ydus_mm); ydu_dd = str2num(ydus_dd);
        
        date = datenum(yyyy(1),ydu_mm,ydu_dd,0,0,0); % File date
        
        % Set file temperature
        temp_cell = data1(:,4);
        temp_num = [];
        for i = 1:length(data1)
            if strcmp(temp_cell(i), '-') % If temperature is '-', replace it as 'NaN'
                temp_num(i,:) = NaN;
            else
                temp_num(i,:) = str2num(cell2mat(temp_cell(i)));
            end
        end
        temperature = temp_num; % Temperature
        
        for di = 1:length(yyyymmdd_day_unique)
            index = find(yyyymmdd_day == yyyymmdd_day_unique(di));
            temp_daily = nanmean(temperature(index));
            temp_daily_all = [temp_daily_all; temp_daily];
        end
        
        xdatenum_all = [xdatenum_all; date];
        
    end
    
    xdatevec = datevec(xdatenum_all);
    xyear = xdatevec(:,1);
    xmonth = xdatevec(:,2);
    xday = xdatevec(:,3);
    
    sst_mean = [];
    sst_std = [];
    temp_daily_all = movmean(temp_daily_all,14);
    for mi = 1:12
        len_day = eomday(1,mi);
        for di = 1:len_day
            index = find(xmonth == mi & xday == di);
            sst_mean = [sst_mean; nanmean(temp_daily_all(index))];
            sst_std = [sst_std; nanstd(temp_daily_all(index))];
        end
    end
    
    xdatenum = datenum(1,1,1):datenum(1,12,31);
    
    for yi = 1:length(yyyy_all)
        
        yyyy = yyyy_all(yi);
        
        %if yyyy == 2013
        
                       
        figure; hold on; grid on
        upart = [sst_mean + sst_std]';
        dpart = [sst_mean - sst_std]';
        
        h = fill([xdatenum, fliplr(xdatenum)], [upart, fliplr(dpart)], [.9 .9 .9]);
        h.LineStyle = 'none';
        h_mean = plot(xdatenum, sst_mean, 'LineWidth', 1, 'Color', 'k');
        
        index = find(xyear == yyyy);
        temp_yi = temp_daily_all(index);
        xdatenum_yi = datenum(1, xmonth(index), xday(index));
        
        if yyyy == 2013
            save([station,'_2013.mat'], 'temp_yi', 'xdatenum_yi')
        end
        
        h = plot(xdatenum_yi, temp_yi, 'LineWidth', 2, 'Color', 'blue');
        
        %h = plot(xdatenum, temp_daily_all(365*i-364:365*i), 'LineWidth', 2, 'Color', [0.3020    0.7490    0.9294]);
        
        ylim([15 30])
        datetick('x', 'mm')
        xlim([datenum(1, 6, 31) datenum(1, 9, 1)])
        xlabel('Month'); ylabel('Temperature (deg C)');
        set(gca, 'FontSize', 15)
        
        l = legend([h_mean, h], ['Mean (', filelist(1).name(end-10:end-7), '-', filelist(end-1).name(end-10:end-7), ')'], num2str(yyyy), 'Location', 'NorthWest');
        l.FontSize = 15;
        %title([station, ' ', num2str(yyyy)])
        saveas(gcf, [station, '_', num2str(yyyy), '.png'])
        
        %else
        %end
        
    end
    close all
end

%
%         datetick('x', 'mm')
%         xlabel('Month', 'FontSize', 15); ylabel('Temperature', 'FontSize', 15);
%         xlim([date(1) date(end)-1]);
%         set(gca, 'FontSize', 15)
%         title([station, ' tidal station daily temp'], 'FontSize', 15)