clear; clc

yyyy = 2019; ystr = num2str(yyyy);

station = [ystr, '_LTC10'];

[num,txt,raw] = xlsread([station, '.csv']);

time_txt = txt(2:end,3);

for ti = 1:length(time_txt)
try
    timenum(ti) = datenum(time_txt(ti), 'yyyy-mm-dd AM HH:MM:SS');
catch
    timenum(ti) = datenum(time_txt(ti), 'yyyy-mm-dd');
end
end

speed = txt(2:end,4);
for i = 1:length(speed)
    speed_tmp = char(speed(i));
    a = 0;
    while ismember('&', speed_tmp(1+a:end))
        a = a+1;
    end
    speed_cms(i) = str2num(speed_tmp(1+a:end));
end

direction = num(:,5)';


degree = 90-direction;
degree(degree < 0) = degree(degree < 0) + 360;

u = speed_cms.*cosd(degree);
v = speed_cms.*sind(degree);

run_t_tide

saveas(gcf, [station, '.png'])