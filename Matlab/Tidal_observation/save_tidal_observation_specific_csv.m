clear; clc

datenum_all = [datenum(2019,1,1):(1/24)/6:datenum(2019,12,31)]';

filepath_all = 'G:\내 드라이브\Research\Counter_current\Observation\장기조류_표층_csv\';
filename_all = {'2019_LTC07.csv', '2019_LTC08.csv', '2019_LTC09.csv', '2019_LTC10.csv', '2019_LTC11.csv', '2019_LTC12.csv'};

udata_all = [0; 0; 0; datenum_all];
vdata_all = [0; 0; 0; datenum_all];
station_all = cell(length(filename_all),1);
for fi = 1:length(filename_all)
    
    clearvars timenum speed_cms u_daily v_daily
    u_all = NaN(size(datenum_all));
    v_all = NaN(size(datenum_all));
    
    filename = filename_all{fi};
    
    station = [filepath_all, filename];
    
    [num,txt,raw] = xlsread([station]);
    
    lat = num(1,2);
    lon = num(2,2);
    dep = num(6,2);
    
    time_txt = txt(10:end,3);
    timenum = [];
    for ti = 1:length(time_txt)
        try
            timenum(ti) = datenum(time_txt(ti), 'yyyy-mm-dd AM HH:MM:SS');
        catch
            timenum(ti) = datenum(time_txt(ti), 'yyyy-mm-dd');
        end
    end
    timenum = timenum - 9/24; % KST to GMT    
    
    speed = txt(10:end,4);
    speed_cms = [];
    for i = 1:length(speed)
        speed_tmp = char(speed(i));
        a = 0;
        while ismember('&', speed_tmp(1+a:end))
            a = a+1;
        end
        speed_cms(i) = str2num(speed_tmp(1+a:end));
    end
    
    direction = num(9:end,5)';
    
    degree = 90-direction;
    degree(degree < 0) = degree(degree < 0) + 360;
    
    u = speed_cms.*cosd(degree);
    v = speed_cms.*sind(degree);
    
%     timenum_unique = unique(floor(timenum));
%     for ti = 1:length(timenum_unique)
%         index = find(floor(timenum) == timenum_unique(ti));
%         u_daily(ti) = nanmean(u(index));
%         v_daily(ti) = nanmean(v(index));
%     end
    
    index = find(diff(timenum) == 0);
    timenum(index) = []; u(index) = []; v(index) = [];

    index = find(ismember(datenum_all, timenum));
    u_all(index) = u;
    v_all(index) = v;
    
    station_all{fi} = filename(1:end-4);
    udata_all = [udata_all [lon; lat; dep; u_all]];
    vdata_all = [vdata_all [lon; lat; dep; v_all]];
end

save Tidal_observation_2019.mat station_all datenum_all udata_all vdata_all