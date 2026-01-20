clear; clc; close all

lon_target = -177;
lat_target = 63.5;
ismap = 0;

if ismap == 1
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Gulf_of_Anadyr', 'mercator', 'l')
    plotm(lat_target, lon_target, 'xr', 'LineWidth', 5, 'MarkerSize', 30)
    print('point_wind', '-dpng')
end

% wgs84 = wgs84Ellipsoid("km");
% angle = 90 - azimuth(62.4042, -180.9088, 64.2745, -173.0732, wgs84);
angle = 45;

yyyy_all = 2010:2025;
mm_start = 4;
dd_start = 15;
timenum_start = datenum(1,mm_start,dd_start);
mm_end = 5;
dd_end = 31;
timenum_end = datenum(1,mm_end,dd_end);

filepath = '/data/jungjih/Models/ERA5/daily/';

timenum = [];
uwind = [];
vwind = [];
wind_NE = [];
wind_NW = [];
wind_NE_sum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for ti = timenum_start:timenum_end
        timenum_tmp = ti;
        timevec_tmp = datevec(timenum_tmp);
        timevec_tmp(:,1) = yyyy;
        timenum_tmp = datenum(timevec_tmp);
        
        mm = timevec_tmp(:,2);
        mstr = num2str(mm, '%02i');
        dd = timevec_tmp(:,3);
        
        filename = ['ERA5_', ystr, mstr, '.nc'];
        file = [filepath, filename];
        timenum_ERA5 = double(ncread(file, 'time'))/24 + datenum(1900,1,1);
        timevec_ERA5 = datevec(timenum_ERA5);
        tindex = find(timevec_ERA5(:,2) == mm & timevec_ERA5(:,3) == dd);
        
        lon_tmp = double(ncread(file, 'longitude'));
        lon_tmp(lon_tmp > 0) = lon_tmp(lon_tmp > 0) - 360;
        lon = lon_tmp;
        lat = double(ncread(file, 'latitude'));
        
        londist = abs(lon - lon_target);
        lonind = find(londist == min(londist));
        latdist = abs(lat - lat_target);
        latind = find(latdist == min(latdist));

        uwind_tmp = squeeze(ncread(file, 'u10', [lonind latind tindex], [1 1 1]));
        vwind_tmp = squeeze(ncread(file, 'v10', [lonind latind tindex], [1 1 1]));
               
        wind_NE_tmp = uwind_tmp.*cosd(-angle) - vwind_tmp.*sind(-angle);
        wind_NW_tmp = uwind_tmp.*sind(-angle) + vwind_tmp.*cosd(-angle);

        timenum = [timenum; timenum_tmp];
        uwind = [uwind; uwind_tmp];
        vwind = [vwind; vwind_tmp];
        wind_NE = [wind_NE; wind_NE_tmp];
        wind_NW = [wind_NW; wind_NW_tmp];
        index = find(wind_NE_tmp<0);
    end
end
timevec = datevec(timenum);

% uwind = [1 1 -1 -1];
% vwind = [1 -1 -1 1];

spd = sqrt(uwind.^2 + vwind.^2);
dir_to_trig_to = atan2(uwind./spd,vwind./spd);
dir = dir_to_trig_to * (180/pi) + 180;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 800])
yyyy_windrose = [2014 2021 2022];
for yi = 1:length(yyyy_windrose)
    yyyy = yyyy_windrose(yi);
    ystr = num2str(yyyy);
    index = find(timevec(:,1) == yyyy);
    dir_tmp = dir(index);
    spd_tmp = spd(index);

    ax = subplot(2,2,yi);
    WindRose(dir_tmp,spd_tmp, ...
        'axes', ax, 'cmap', 'jet', ...
        'AngleNorth',0,'AngleEast',90, ...
        'TitleString',{ystr, ''}, ...
        'maxfrequency', 15, 'nfreq',5, ...
        'vwinds', [0:2:12], 'FreqLabelAngle',45);
    if yi == length(yyyy_windrose)
        h = get(gca);
        l = h.Legend;
        l.FontSize = 12;
        l.Position = [0.6 0.15 0.2143 0.2119];
    else
        h = get(gca);
        delete(h.Legend)
    end
    h.Children(5).String = '';
end

uwind_data = [];
vwind_data = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    index = find(timevec(:,1) == yyyy);
    uwind_data(:,yi) = uwind(index);
    vwind_data(:,yi) = vwind(index);
end
uwind_mean = mean(uwind_data,2);
vwind_mean = mean(vwind_data,2);

spd_mean = sqrt(uwind_mean.^2 + vwind_mean.^2);
dir_to_trig_to = atan2(uwind_mean./spd_mean,vwind_mean./spd_mean);
dir_mean = dir_to_trig_to * (180/pi) + 180;

asdfasdf

figure; 
WindRose(dir_mean,spd_mean, ...
        'cmap', 'jet', ...
        'AngleNorth',0,'AngleEast',90, ...
        'TitleString',{ystr, ''}, ...
        'maxfrequency', 20, 'nfreq',4, ...
        'vwinds', [0:2:12], 'FreqLabelAngle',45);


asdfasdf
save(['wind_point_', mstr, '.mat'], 'timenum', 'wind_NE', 'wind_NW')