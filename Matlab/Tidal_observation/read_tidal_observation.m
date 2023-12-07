clear; clc

yyyy_all = 2015:2020;

filepath = 'D:\Data\Ocean\ADCP\국립해양조사원_남해_장기조류관측\조류관측자료(`15_`20)\';

for yi = 1:length(yyyy_all)
    
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    filelist = dir([filepath, ystr(3:4), 'LTC*']);
    
    if ~isempty(filelist)
        
        for fi = 1:length(filelist)
            filename = filelist(fi).name;
            station(fi,:) = filename(1:7);
            position = filename(9);
            
            file = [filepath, filename];
            
            data = read_tidal_observation_function(file);
            location = read_tidal_observation_location_function(file);
            lat_raw = table2array(location(1,:));
            lon_raw = table2array(location(2,:));
            
            depth = table2array(read_tidal_observation_depth_function(file));
            dstr = num2str(depth);
            
            lat(fi) = lat_raw(1) + lat_raw(2)/60 + lat_raw(3)/3600;
            lon(fi) = lon_raw(1) + lon_raw(2)/60 + lon_raw(3)/3600;
            
            yyyy = table2array(data(:,1));
            mm = table2array(data(:,2));
            dd = table2array(data(:,3));
            HH = table2array(data(:,4));
            MM = table2array(data(:,5));
            
            timenum = datenum(yyyy,mm,dd,HH,MM,0);
            
            speed_cms = table2array(data(:,6));
            direction = table2array(data(:,7));
            temp = table2array(data(:,8));
            
            degree = 90-direction;
            degree(degree < 0) = degree(degree < 0) + 360;
            
            u = speed_cms.*cosd(degree);
            v = speed_cms.*sind(degree);
            
            if strcmp(position, 'B')
                figure; hold on; grid on
                p2 = plot(timenum, movmean(u,6*24*14), 'b', 'LineWidth', 2);
            else
                p1 = plot(timenum, movmean(u,6*24*14), 'r', 'LineWidth', 2);
                
                ylim([-20 20])
                datetick('x', 'mmm-dd');
                ylabel('cm/s')
                
                l = legend([p1, p2], 'Surface', 'Bottom');
                
                title([station(fi,:), ' (', dstr, ' m)'])
                set(gca, 'FontSize', 12)
                
                saveas(gcf, [station(fi,:), '_', ystr, '.png'])
            end
            
        end
        figure;
        map_J('southern')
        m_plot(lon, lat, '.r', 'MarkerSize', 30)
        for li = 1:2:length(lon)
            m_text(lon(li), lat(li)-.1, station(li,:), 'color', 'r', 'FontSize', 15)
        end
        saveas(gcf, ['point_', ystr, '.png'])
        clearvars station lon lat
    end
end
