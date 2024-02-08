%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare DTU15 geoid with Matlab geoid obtained by geoidheight (EGM96)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

lon_range = [-205.9832 -156.8640]; lat_range = [49.1090 66.3040]; % Bering Sea

filepath_DTU15 = '/data/jungjih/Observations/Satellite_SSH/DTU15/';
filename_mss = 'DTU15MSS_1min.nc';
filename_mdt = 'DTU15MDT_1min.mdt.nc';

file_mss = [filepath_DTU15, filename_mss];
lon_DTU15 = ncread(file_mss, 'lon') - 360;
lat_DTU15 = ncread(file_mss, 'lat');

index_lon = find(lon_DTU15 > lon_range(1) -1 & lon_DTU15 < lon_range(2) + 1);
index_lat = find(lat_DTU15 > lat_range(1) -1 & lat_DTU15 < lat_range(2) + 1);

lon_DTU15_Bering_Sea = lon_DTU15(index_lon);
lat_DTU15_Bering_Sea = lat_DTU15(index_lat);

mss = ncread(file_mss, 'mss')';
mss_DTU15_Bering_Sea = mss(index_lat, index_lon);

file_mdt = [filepath_DTU15, filename_mdt];
mdt = ncread(file_mdt, 'mdt')';
mdt_DTU15_Bering_Sea = mdt(index_lat, index_lon);

geoid_DTU15_Bering_Sea = mss_DTU15_Bering_Sea - mdt_DTU15_Bering_Sea;

[lon2, lat2] = meshgrid(lon_DTU15_Bering_Sea, lat_DTU15_Bering_Sea);
geoid_matlab = geoidheight(lat2, lon2);

figure; hold on; grid on
set(gcf, 'Position', [1 1 1800 400])
tiledlayout(1,3);
nexttile(1)
pcolor(lon_DTU15_Bering_Sea, lat_DTU15_Bering_Sea, geoid_DTU15_Bering_Sea); shading interp;
caxis([-15 30])
colorbar
title('DTU15 geoid (1 min)')

nexttile(2)
pcolor(lon_DTU15_Bering_Sea, lat_DTU15_Bering_Sea, geoid_matlab); shading interp;
caxis([-15 30])
colorbar
title('Matlab EGM96 geoid (15 min)')

nexttile(3)
pcolor(lon_DTU15_Bering_Sea, lat_DTU15_Bering_Sea, geoid_DTU15_Bering_Sea - geoid_matlab); shading interp;
ax = gca;
colormap(ax, 'redblue')
caxis([-2 2])
colorbar
title('Difference (DTU15 - EGM96)')

print('Compare_geoid_DTU15_EGM96', '-dpng');

save DTU15_1min_Bering_Sea.mat lon_DTU15_Bering_Sea lat_DTU15_Bering_Sea mss_DTU15_Bering_Sea mdt_DTU15_Bering_Sea geoid_DTU15_Bering_Sea