%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical velocity uv to ADCP from Bering Sea mooring data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
g = grd('BSf');
startdate = datenum(2018,7,1);
filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

period = datenum(2022,1,1):datenum(2022,4,1);

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/';
filename_obs = 'ADCP_Full_bsp8_record_6241_ad11_f0e2.nc';
file_obs = [filepath_obs, filename_obs];

lon_obs = ncread(file_obs, 'lon');
lat_obs = ncread(file_obs, 'lat');
time_obs = ncread(file_obs, 'time');
timenum_obs = time_obs/60/60/24 + datenum(1970,1,1);
depth_obs = ncread(file_obs, 'depth');
u_obs = ncread(file_obs, 'u_comp_current');
v_obs = ncread(file_obs, 'v_comp_current');

z_model_daily = [];
u_model_daily = [];
v_model_daily = [];
depth_obs_daily = [];
u_obs_daily = [];
v_obs_daily = [];
for ti = 1:length(period)

    filenum = period(ti) - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];
    timenum_daily(ti) = ncread(file, 'ocean_time')/60/60/24 + datenum(1968,5,23);

    % Obs
    tindex = find(timenum_obs >= timenum_daily(ti)-0.5 & timenum_obs < timenum_daily(ti)+0.5);
    point_lon = mean(mean(lon_obs(:,tindex), 'omitnan'), 'omitnan');
    if point_lon > 0
        point_lon = point_lon - 360;
    end
    point_lat = mean(mean(lat_obs(:,tindex), 'omitnan'), 'omitnan');

    u_obs_tmp = u_obs(:,tindex);
    v_obs_tmp = v_obs(:,tindex);

    depth_obs_daily(:,ti) = depth_obs;
    u_obs_daily(:,ti) = mean(u_obs_tmp, 2);
    v_obs_daily(:,ti) = mean(v_obs_tmp, 2);

    % Model
    dist = sqrt((g.lon_rho - point_lon).^2 + abs(g.lat_rho - point_lat).^2);
    [latind, lonind] = find(dist == min(dist(:)));
    dist = sqrt((g.lon_u - point_lon).^2 + abs(g.lat_u - point_lat).^2);
    [ulatind, ulonind] = find(dist == min(dist(:)));
    dist = sqrt((g.lon_v - point_lon).^2 + abs(g.lat_v - point_lat).^2);
    [vlatind, vlonind] = find(dist == min(dist(:)));

    zeta = ncread(file, 'zeta', [lonind, latind, 1], [1 1 Inf]);
    h = ncread(file, 'h', [lonind, latind], [1 1]);
    depth = zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    depth = abs(depth);

    u = squeeze(ncread(file, 'u', [ulonind, ulatind, 1, 1], [1, 1, Inf, Inf]));
    v = squeeze(ncread(file, 'v', [vlonind, vlatind, 1, 1], [1, 1, Inf, Inf]));

    z_model_daily(:,ti) = depth;
    u_model_daily(:,ti) = u*100;
    v_model_daily(:,ti) = v*100;

    disp(datestr(timenum_daily(ti), 'yyyymmdd'))
end % ti

figure; hold on; grid on;
plot(timenum_daily, u_obs_daily(1,:));
plot(timenum_daily, u_model_daily(45,:));
datetick('x', 'mmm, yyyy')
ylim([-100 100])

figure; hold on; grid on;
plot(timenum_daily, u_obs_daily(53,:));
plot(timenum_daily, u_model_daily(8,:));
datetick('x', 'mmm, yyyy')
ylim([-100 100])

figure; hold on; grid on;
plot(timenum_daily, v_obs_daily(1,:));
plot(timenum_daily, v_model_daily(45,:));
datetick('x', 'mmm, yyyy')
ylim([-100 100])

figure; hold on; grid on;
plot(timenum_daily, v_obs_daily(53,:));
plot(timenum_daily, v_model_daily(8,:));
datetick('x', 'mmm, yyyy')
ylim([-100 100])


asdf

% Map
f1 = figure; hold on;
set(gcf, 'Position', [1 200 500 500])
plot_map('Eastern_Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    point_location = points_location(point,:);
    point_lat = point_location(1);
    point_lon = point_location(2);

    plotm(point_lat, point_lon, '.r', 'MarkerSize', 15)
    textm(point_lat+0.5, point_lon, point_name, 'Color', 'r', 'FontSize', 15)
end
print('map_ADCP', '-dpng')
