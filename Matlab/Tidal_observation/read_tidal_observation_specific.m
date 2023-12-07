clear; clc

%station_all = {'18LTC07_S', '19LTC12_S', '20LTC06_S'};
%station_all = {'19LTC07_S', '19LTC08_S', '19LTC09_S', '19LTC10_S', '19LTC11_S', '19LTC12_S'};
%station_all = {'19LTC07_S', '19LTC09_S', '19LTC12_S'};
station_all = {'19LTC07_S', '19LTC08_S', '19LTC09_S', '19LTC10_S', '19LTC11_S', '19LTC12_S'};

filepath = 'D:\Data\Ocean\ADCP\국립해양조사원_남해_장기조류관측\조류관측자료(`15_`20)\';

figure; hold on; grid on
for si = 1:length(station_all)
    
    station = station_all{si};
    
    filelist = dir([filepath, '*', station, '*']);
    
    filename = filelist.name;
    
    file = [filepath, filename];
    
    data = read_tidal_observation_function(file);
    location = read_tidal_observation_location_function(file);
    lat_raw = table2array(location(1,:));
    lon_raw = table2array(location(2,:));
    
    depth = table2array(read_tidal_observation_depth_function(file));
    dstr = num2str(depth);
    
    lat(si) = lat_raw(1) + lat_raw(2)/60 + lat_raw(3)/3600;
    lon(si) = lon_raw(1) + lon_raw(2)/60 + lon_raw(3)/3600;
    
    yyyy = table2array(data(:,1));
    mm = table2array(data(:,2));
    dd = table2array(data(:,3));
    HH = table2array(data(:,4));
    MM = table2array(data(:,5));
    
    timenum = datenum(yyyy,mm,dd,HH,MM,0) - 9/24;
    
    speed_cms = table2array(data(:,6));
    direction = table2array(data(:,7));
    temp = table2array(data(:,8));
    
    degree = 90-direction;
    degree(degree < 0) = degree(degree < 0) + 360;
    
    u = speed_cms.*cosd(degree);
    v = speed_cms.*sind(degree);
    
    %%%%%
    timenum_unique = unique(floor(timenum));
    clearvars u_daily v_daily
    for ti = 1:length(timenum_unique)
        index = find(floor(timenum) == timenum_unique(ti));
        u_daily(ti) = nanmean(u(index));
        v_daily(ti) = nanmean(v(index));
        temp_daily(ti) = nanmean(temp(index));
    end
    xtick_list = [datenum(2000 + str2num(station(1:2)),1:12,1)];
    
%     p1(si) = plot(timenum_unique, u_daily, 'LineWidth', 2);
%     set(gca, 'xtick', xtick_list)
%     ylim([-50 50])
%     datetick('x', 'mmm-dd', 'keepticks');
%     xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),7,31)]);
%     ylabel('cm/s')
%     l = legend(p1, station_all, 'Interpreter', 'none');
%     l.Location = 'SouthWest';
%     title([station, ' (daily, ', dstr, ' m)'], 'interpreter', 'none')
%     set(gca, 'FontSize', 15)
    
    u = u(1:6:end);
    timenum = timenum(1:6:end);
    filter_hour = 72;
    fpass = 1/filter_hour;
    Fs = 1; n = 8; Wn = fpass; Fn = Fs/2; ftype = 'low';
    [b,a] = butter(n,Wn/Fn,ftype);
    obs_u_lowpass = filtfilt(b,a,u);
    
    p1(si) = plot(timenum, obs_u_lowpass, 'LineWidth', 2);
    set(gca, 'xtick', xtick_list)
    ylim([-50 50])
    datetick('x', 'mmm-dd', 'keepticks');
    xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),7,31)]);
    ylabel('cm/s')
    l = legend(p1, station_all, 'Interpreter', 'none');
    l.Location = 'SouthWest';
    title([station, ' (daily, ', dstr, ' m)'], 'interpreter', 'none')
    set(gca, 'FontSize', 15)

    
%     load([station, '.mat'])
%     timenum_model1 = [datenum(2000 + str2num(station(1:2)),1,1):datenum(2000 + str2num(station(1:2)),12,31)];
%     u_surf_target1 = u_surf_target*100;
%     
%     figure; hold on; grid on
%     p1 = plot(timenum_unique, u_daily, 'r', 'LineWidth', 1);
%     p2 = plot(timenum_model1, u_surf_target1, 'g', 'LineWidth', 1);
%     set(gca, 'xtick', xtick_list)
%     ylim([-50 50])
%     datetick('x', 'mmm-dd', 'keepticks');
%     xlim([datenum(yyyy(1),6,1) datenum(yyyy(1),9,30)]);
%     ylabel('cm/s')
%     l = legend([p1, p2], 'Observation', 'Model (6-8 km)');
%     l.Location = 'SouthWest';
%     title([station, ' (daily, ', dstr, ' m)'], 'interpreter', 'none')
%     set(gca, 'FontSize', 15)
%     
%     saveas(gcf, [station, '_obs_vs_model_daily.png'])
    
end
