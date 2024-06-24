%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS velocity ADCP ASGARD data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

period = datenum(2017,6,1):datenum(2019,8,31);

points = [1 2 3 4];
points_name = {'N1', 'N2', 'N3', 'N4'};
points_location = [;
    63.2965, -168.43;
    64.1545, -171.526;
    64.3895, -167.086;
    64.9284, -169.9182;
    ];
points_max_depth = [; 
%2017-18, 2018-19
    33.3, 36.6 % N1
    37.1, 37.1 % N2, No data in 2018-19
    20.5, 20.5 % N3, No data in 2018-19
    39.5, 39.7 % N4
    ];

% Model
g = grd('BSf');
startdate = datenum(2018,7,1);
filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm2_spng/';

% Observation
filepath_obs = '/data/jungjih/Observations/ADCP/ASGARD/';

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    point_location = points_location(point,:);
    point_lat = point_location(1);
    point_lon = point_location(2);
    filenames_obs = dir([filepath_obs, point_name, '*']);

    dist = sqrt((g.lon_rho - point_lon).^2 + abs(g.lat_rho - point_lat).^2);
    [latind, lonind] = find(dist == min(dist(:)));

    dist = sqrt((g.lon_u - point_lon).^2 + abs(g.lat_u - point_lat).^2);
    [ulatind, ulonind] = find(dist == min(dist(:)));

    dist = sqrt((g.lon_v - point_lon).^2 + abs(g.lat_v - point_lat).^2);
    [vlatind, vlonind] = find(dist == min(dist(:)));

    if exist([point_name, '.mat']) == 0

    timenum_all = [];
    depth_all = [];
    u_all = [];
    v_all = [];
    fi_all = [];
    for fi = 1:length(filenames_obs)
        filename_obs = filenames_obs(fi).name;
        file_obs = [filepath_obs, filename_obs];
        data = readtable(file_obs);

        yyyy = table2array(data(:,1));
        mm = table2array(data(:,2));
        dd = table2array(data(:,3));
        HH = table2array(data(:,4));
        MM = table2array(data(:,5));
        depth = table2array(data(:,7));
        u = table2array(data(:,10));
        v = table2array(data(:,11));

        timenum = datenum(yyyy,mm,dd,HH,MM,0);

        timenum_all = [timenum_all; timenum];
        if fi == 1
            timenum_interim = max(timenum);
        end
        depth_all = [depth_all; depth];
        u_all = [u_all; u];
        v_all = [v_all; v];
        fi_all = [fi_all; zeros(size(timenum))+fi];
    end % fi
        
    depth_obs = points_max_depth(pi,:);
    dindex = find(depth_all == depth_obs(1) | depth_all == depth_obs(2));

    timenum_target = timenum_all(dindex);
    u_target = u_all(dindex);
    v_target = v_all(dindex);

    timenum_daily = period;
    u_model_daily = [];
    v_model_daily = [];
    u_obs_daily = [];
    v_obs_daily = [];
    for ti = 1:length(timenum_daily)
        tindex = find(floor(timenum_target) == timenum_daily(ti));
        u_obs_daily(ti) = mean(u_target(tindex));
        v_obs_daily(ti) = mean(v_target(tindex));

        if timenum_daily(ti) > timenum_interim
            depth_target = depth_obs(2);
        else
            depth_target = depth_obs(1);
        end

        filenumber = timenum_daily(ti) - startdate + 1;
        fstr = num2str(filenumber, '%04i');
        filename = ['Dsm2_spng_avg_', fstr, '.nc'];
        file = [filepath, filename];
        
        if exist(file) ~= 0
            u = ncread(file, 'u'); u = permute(u, [3 2 1]);
            v = ncread(file, 'v'); v = permute(v, [3 2 1]);

            z_point = g.z_r(:,latind, lonind);
            u_point = u(:, ulatind, ulonind);
            v_point = v(:, vlatind, vlonind);

            u_model_daily(ti) = interp1(z_point, u_point, -depth_target)*100;
            v_model_daily(ti) = interp1(z_point, v_point, -depth_target)*100;
        else
            u_model_daily(ti) = NaN;
            v_model_daily(ti) = NaN;
        end
        depth_model = g.h(latind, lonind);

        disp(datestr(timenum_daily(ti), 'yyyymmdd'))
    end % ti
    save([point_name, '.mat'], 'timenum_daily', 'u_model_daily', 'v_model_daily', 'u_obs_daily', 'v_obs_daily', 'depth_obs', 'depth_model');
    end % exist
end % pi
sdfasdfaf

% Map
f1 = figure; hold on;
set(gcf, 'Position', [1 200 500 500])
plot_map('Eastern_Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');

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

% v plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load(point_name);

    nexttile(5-pi); hold on; grid on

    p1 = plot(timenum_daily, v_model_daily);
    p2 = plot(timenum_daily, v_obs_daily);
%     xticks([datenum(2018,7:12,1) datenum(2019,1:8,1)])
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('cm/s');
    ylim([-80 80]);

    l = legend([p1, p2], 'ROMS', 'ADCP');
    l.Location = 'NorthWest';

    title([point_name, ' near bottom ', '(2017-18 = ', num2str(depth_obs(1)), ' m, 2018-19 = ', num2str(depth_obs(2)), ') meridional velocity'])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';

print('cmp_vvel_w_ADCP', '-dpng')

% u plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load(point_name);

    nexttile(5-pi); hold on; grid on

    p1 = plot(timenum_daily, u_model_daily);
    p2 = plot(timenum_daily, u_obs_daily);
%     xticks([datenum(2018,7:12,1) datenum(2019,1:8,1)])
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('cm/s');
    ylim([-80 80]);

    l = legend([p1, p2], 'ROMS', 'ADCP');
    l.Location = 'NorthWest';

    title([point_name, ' near bottom ', '(2017-18 = ', num2str(depth_obs(1)), ' m, 2018-19 = ', num2str(depth_obs(2)), ') zonal velocity'])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';

print('cmp_uvel_w_ADCP', '-dpng')