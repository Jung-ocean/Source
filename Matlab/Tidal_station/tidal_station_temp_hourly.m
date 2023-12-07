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
    target_year = 2013; tys = num2str(target_year);
    
    % File
    filepath = 'D:\Data\Ocean\조위관측소\TS\';
    filelist = dir([filepath, '*', station, '*']);
    
    figure; hold on;
    for fi = 1:length(filelist)
        
        file = [filepath, filelist(fi).name];
        % Read all data as string
        [num, yyyymmdd, hhhh, temp, salt] = textread(file, '%s %s %s %s %s', 'headerlines', 6);
        data1 = [num, yyyymmdd, hhhh, temp, salt];
        
        % Set file date
        yyyymmdd = cell2mat(data1(:,2));
        yyyy = str2num(yyyymmdd(:,1:4));
        yyyy_all(fi) = yyyy(1);
        mm = str2num(yyyymmdd(:,6:7));
        dd = str2num(yyyymmdd(:,9:10));
        
        hhhh = cell2mat(data1(:,3));
        hh = str2num(hhhh(:,1:2));
        
        date = datenum(target_year,mm,dd,hh,0,0); % File date
        
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
        
        % Plot
        if yyyy == target_year;
            color = 'r';
            h_target = plot(date, temperature, '.', 'Color', color);
        else
            color = [.502 .502 .502];
            h = plot(date, temperature, '.', 'Color', color);
        end
        datetick('x', 'mm')
        xlabel('Month', 'FontSize', 15); ylabel('Temperature', 'FontSize', 15);
        xlim([date(end) date(1)-1]);
        set(gca, 'FontSize', 15)
        title([station, ' tidal station hourly temp'], 'FontSize', 15)
        
        if fi == length(filelist)
            legend([h h_target], [num2str(yyyy_all(1)), '-', num2str(yyyy_all(end))], tys, 'Location', 'NorthWest')
        end
    end
    uistack(h_target, 'top')
    saveas(gcf, [station, '_hourly.png'])
    
end