clear; clc

filepath = '/data/serofeev/RTDAOW2/ETA/surface/';

swrad_all = [];
for ti = 0:3:84
    tstr = num2str(ti, '%02i');
    filename = ['nam12b_sfc_2025032000f', tstr];
    file = [filepath, filename];
    data = importdata(file);

    swrad_all = [swrad_all; data(:,9)];

end

figure; hold on; grid on;
plot(swrad_all);
plot(movmean(swrad_all, 400))