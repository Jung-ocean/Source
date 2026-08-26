%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Comparison between NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/General'])

vari_str = 'swrad_down';
location = 'WA_shelf';
title_str = replace(location, '_', ' ');

yyyy = 2024;
ystr = num2str(yyyy);
datenum_start = datenum(yyyy,5,1);
datenum_end = datenum(yyyy,9,30);

switch location
    case 'OR_shelf'
        lat_target = 44.6393;
        lon_target = -124.304;
        file_obs = '/data/jungjih/Observations/OOI_buoy/Oregon_shelf/ooi-ce02shsm-sbd11-06-metbka000_9929_5811_ec50.nc';
    case 'WA_shelf'
        lat_target = 46.9859;
        lon_target = -124.566;
        file_obs = '/data/jungjih/Observations/OOI_buoy/Washington_shelf/ooi-ce07shsm-sbd11-06-metbka000_3c79_9121_96b4.nc';
end

timenum_obs_tmp = ncread(file_obs, 'time')/60/60/24 + datenum(1970,1,1);
tindex = find(timenum_obs_tmp >= datenum_start & timenum_obs_tmp <= datenum_end);
timenum_obs = timenum_obs_tmp(tindex);
vari_obs = ncread(file_obs, 'downwelling_shortwave_flux_in_air', [tindex(1)], [length(tindex)]);

timenum_obs_daily = datenum_start:datenum_end;
vari_obs_daily = NaN(length(timenum_obs_daily),1);
for ti = 1:length(timenum_obs_daily)
    timenum_tmp = timenum_obs_daily(ti);
    index = find(timenum_obs >= timenum_tmp & timenum_obs < timenum_tmp+1/24);
    vari_obs_daily(ti) = mean(vari_obs(index));
end

ismap = 0;
if ismap == 1
    % Map
    g = grd('Oregon_1km');
    figure;
    set(gcf, 'Position', [1 200 500 800])
    plot_map('Oregon', 'mercator', 'l');
    [cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');
    cl = clabelm(cs, h);
    set(cl, 'BackgroundColor', 'none');
    plotm(lat_target, lon_target, 'xr', 'MarkerSize', 12, 'LineWidth', 4);
    print(['map_cmp_swrad_down_', location], '-dpng')
end

% CFSv2
filepath = '/data/jungjih/Models/CFSv2/netcdf_sub/';
filename = ['dswsfc_', ystr, '.nc'];
file = [filepath, filename];
time_CFSv2 = ncread(file, 'time');
timenum_CFSv2_tmp = datenum(1970,1,1) + time_CFSv2/60/60/24;
lon = ncread(file, 'longitude');
lon = lon-360;
lat = ncread(file, 'latitude');

tindex = find(timenum_CFSv2_tmp >= datenum_start & timenum_CFSv2_tmp <= datenum_end);
timenum_CFSv2 = timenum_CFSv2_tmp(tindex);
vari_CFSv2 = ncread(file, 'DSWRF_surface', [1 1 tindex(1)], [Inf Inf length(tindex)]);

[lat2, lon2] = meshgrid(lat, lon);
F = scatteredInterpolant(lon2(:), lat2(:), 0.*lat2(:));

timenum_CFSv2_daily = timenum_obs_daily;
vari_CFSv2_daily = NaN(length(timenum_CFSv2_daily),1);
for ti = 1:length(timenum_CFSv2_daily)
    timenum_tmp = timenum_CFSv2_daily(ti);
    index = find(timenum_CFSv2 >= timenum_tmp & timenum_CFSv2 < timenum_tmp+1/24);
    vari_CFSv2_tmp = mean(vari_CFSv2(:,:,index), 3);
    F.Values = vari_CFSv2_tmp(:);
    vari_CFSv2_daily(ti) = F(lon_target, lat_target);
end

% ERA5
filepath = '/data/jungjih/Models/ERA5/hourly/';
filename = ['ERA5_2024.nc'];
file = [filepath, filename];
ERA5_time = double(ncread(file, 'time'));
timenum_ERA5_tmp = datenum(1900,1,1) + ERA5_time/24;
lon = double(ncread(file, 'longitude'));
lon(lon>0) = lon(lon>0)-360;
lat = double(ncread(file, 'latitude'));

tindex = find(timenum_ERA5_tmp >= datenum_start & timenum_ERA5_tmp <= datenum_end);
timenum_ERA5 = timenum_ERA5_tmp(tindex);
vari_ERA5 = ncread(file, 'msdwswrf', [1 1 tindex(1)], [Inf Inf length(tindex)]);

[lat2, lon2] = meshgrid(lat, lon);
F = scatteredInterpolant(lon2(:), lat2(:), 0.*lat2(:));

timenum_ERA5_daily = timenum_obs_daily;
vari_ERA5_daily = NaN(length(timenum_ERA5_daily),1);
for ti = 1:length(timenum_ERA5_daily)
    timenum_tmp = timenum_ERA5_daily(ti);
    index = find(timenum_ERA5 >= timenum_tmp & timenum_ERA5 < timenum_tmp+1/24);
    vari_ERA5_tmp = mean(vari_ERA5(:,:,index), 3);
    F.Values = vari_ERA5_tmp(:);
    vari_ERA5_daily(ti) = F(lon_target, lat_target);
end

% Figure
figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pm = plot(timenum_CFSv2_daily, vari_CFSv2_daily, '-k', 'LineWidth', 2);
pe = plot(timenum_ERA5_daily, vari_ERA5_daily, '-g', 'LineWidth', 2);
po = plot(timenum_obs_daily, vari_obs_daily, '-r', 'LineWidth', 2);
xlim([datenum_start-1 datenum_end+1]);
ylim([0 1100])
xticks(datenum(yyyy,1:12,1))
datetick('x', 'mm/dd/yyyy', 'keepticks', 'keeplimits')
ylabel('W/m^2');
set(gca, 'FontSize', 15)

title(['Downward shortwave radiation (', title_str, ')'])

l = legend([pm, pe, po], 'CFSv2', 'ERA5', ['OOI buoy (', title_str, ')']);
l.Location = 'SouthOutside';
l.NumColumns = 3;
asdf
print(['cmp_swrad_down_', location, '_', ystr], '-dpng')