clear; clc

filepath = '/data/jungjih/Observations/WOA/';
filename = 'woa18_decav_I00_01.nc';
file = [filepath, filename];

lon = ncread(file, 'lon');
lat = ncread(file, 'lat');
depth = ncread(file, 'depth');
rho = ncread(file, 'I_an');

rho_mean = squeeze(mean(mean(rho, 1, 'omitnan'), 2, 'omitnan'));

figure; hold on; grid on;
plot(rho_mean, -depth)