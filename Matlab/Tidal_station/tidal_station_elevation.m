clear; clc

yyyy_all = 2020:2020;
stations = {'거문도', '거제도', '고흥발포', '여수'};

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    for si = 1:length(stations)
        station = stations{si};
        
        filepath = 'D:\Data\Ocean\조위관측소\all\';
        filename = [ystr, '_', station, '.txt'];
        file = [filepath, filename];
        
        data = tidal_station_all_function(file);
        yyyymmddHH = data{:,1};
        time = datenum(yyyymmddHH) - 9/24;
        timevec = datevec(time);
        
        xticks = datenum(yyyy,1:12,1,0,0,0);
        
        elevation = data{:,2};
        %%%%%
        timenum_unique = unique(floor(time));
        clearvars elevation_daily
        for ti = 1:length(timenum_unique)
            index = find(floor(time) == timenum_unique(ti));
            elevation_daily(ti) = nanmean(elevation(index));
        end
        
        figure; hold on; grid on
        plot(timenum_unique, elevation_daily, 'k')
        
        set(gca, 'xtick', xticks)
        datetick('x', 'mm', 'keepticks')
        xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),9,30)]);
        %xlim([datenum(yyyy,4,1) datenum(yyyy,10,1)])
        xlabel('Month')
        ylabel('cm')
        %ylim([150 250])
        
        save([station, '_elevation.mat'], 'time', 'elevation', 'timenum_unique', 'elevation_daily')
    end
end