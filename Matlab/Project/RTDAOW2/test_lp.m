clear; clc

lon_target = 230;
lat_target = 45;

t_all = 3:3:192;

filepath = '/data/jungjih/RTDAOW2/Data/SSH/tmp/';

ssh_all = NaN(length(t_all), 1);
for ti = 1:length(t_all)
    t_tmp = t_all(ti);
    tstr = num2str(t_tmp, '%04i');

    filename = ['US058GCOM-OPSnce.espc-d-031-hycom_fcst_glby008_2026020112_t', tstr, '_ssh.nc'];
    file = [filepath, filename];

    if ti == 1
        lon = ncread(file, 'lon');
        lat = ncread(file, 'lat');
        
        londis = abs(lon - lon_target);
        lonind = find(londis == min(londis));
        latdis = abs(lat - lat_target);
        latind = find(latdis == min(latdis));
    end
    
    ssh_tmp = ncread(file, 'surf_el', [lonind, latind, 1], [1, 1, 1]);
    ssh_all(ti) = ssh_tmp;
end

addpath(['/data/jungjih/RTDAOW2/matlib/FUNCTIONS/']);
time_day = t_all/24;
ssh_all = [ssh_all'; ssh_all'];
[vari_lp, time_lp] = OSUlpAK(ssh_all, time_day);

fs = 1/3;
fpass = 1/40;
y = lowpass(ssh_all(1,:), fpass, fs);

figure; hold on; grid on;
plot(time_day, ssh_all(1,:), 'k');
plot(time_lp, vari_lp(1,:), '-r');
plot(time_day, y, '-g');