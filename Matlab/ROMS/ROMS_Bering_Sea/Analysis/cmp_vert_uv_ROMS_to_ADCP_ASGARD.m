%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical velocity uv to ADCP ASGARD data
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

    if exist([point_name, '_vert_uv.mat']) == 0

    timenum_all = [];
    depth_all = [];
    u_all = [];
    v_all = [];
    len_depth = [];
    depth_list = [];
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
        len_depth(fi) = length(unique(depth));
        depth_list{fi} = unique(depth);
    end % fi

    timenum_daily = period;
    z_model_daily = [];
    u_model_daily = [];
    v_model_daily = [];
    depth_obs_daily = [];
    u_obs_daily = [];
    v_obs_daily = [];
    for ti = 1:length(timenum_daily)
        tindex = find(floor(timenum_all) == timenum_daily(ti));

        timenum_target = timenum_all(tindex);
        depth_target = depth_all(tindex);
        depth_unique = unique(depth_target);
        u_target = u_all(tindex);
        v_target = v_all(tindex);

        if length(depth_unique) > max(len_depth)
            maxind = find(len_depth == max(len_depth));
            index = find(ismember(depth_target, depth_list{maxind}));

            depth_target = depth_target(index);
            depth_unique = unique(depth_target);
            u_target = u_target(index);
            v_target = v_target(index);
        end

        if isempty(tindex) ~= 1
            for di = 1:length(depth_unique)
                dindex = find(depth_target == depth_unique(di));

                depth_obs_daily(di,ti) = mean(depth_target(dindex));
                u_obs_daily(di,ti) = mean(u_target(dindex));
                v_obs_daily(di,ti) = mean(v_target(dindex));
            end
        else
            depth_obs_daily(:,ti) = NaN(max(len_depth), 1);
            u_obs_daily(:,ti) = NaN(max(len_depth), 1);
            v_obs_daily(:,ti) = NaN(max(len_depth), 1);
        end

        % Fill the gap
        if length(depth_unique) < max(len_depth)
            depth_obs_daily(length(depth_unique)+1:max(len_depth),ti) = NaN;
            u_obs_daily(length(depth_unique)+1:max(len_depth),ti) = NaN;
            v_obs_daily(length(depth_unique)+1:max(len_depth),ti) = NaN;
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
            
            z_model_daily(:,ti) = z_point;
            u_model_daily(:,ti) = u_point*100;
            v_model_daily(:,ti) = v_point*100;
        else
            z_model_daily(:,ti) = NaN(g.N, 1);
            u_model_daily(:,ti) = NaN(g.N, 1);
            v_model_daily(:,ti) = NaN(g.N, 1);
        end

        disp(datestr(timenum_daily(ti), 'yyyymmdd'))
    end % ti
    depth_model = g.h(latind, lonind);
    save([point_name, '_vert_uv.mat'], 'timenum_daily', 'z_model_daily', 'u_model_daily', 'v_model_daily', 'depth_obs_daily', 'u_obs_daily', 'v_obs_daily', 'depth_model');
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

% ADCP v plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_uv.mat']);

    nexttile(5-pi); hold on; grid on

    pcolor(timenum_daily, -depth_obs_daily, v_obs_daily); shading interp
    ylim([-50 0])
    colormap redblue
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('m');

    c = colorbar; 
    c.Title.String = 'cm/s';
    caxis([-80 80]);

    title([point_name])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'ADCP meridional velocity')

print('ADCP_vert_vvel', '-dpng')

% ROMS v plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_uv.mat']);

    nexttile(5-pi); hold on; grid on

    pcolor(timenum_daily, z_model_daily, v_model_daily); shading interp
    ylim([-50 0])
    colormap redblue
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('m');

    c = colorbar; 
    c.Title.String = 'cm/s';
    caxis([-80 80]);

    title([point_name])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'ROMS meridional velocity')

print('ROMS_vert_vvel', '-dpng')

% ADCP u plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_uv.mat']);

    nexttile(5-pi); hold on; grid on

    pcolor(timenum_daily, -depth_obs_daily, u_obs_daily); shading interp
    ylim([-50 0])
    colormap redblue
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('m');

    c = colorbar; 
    c.Title.String = 'cm/s';
    caxis([-80 80]);

    title([point_name])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'ADCP zonal velocity')

print('ADCP_vert_uvel', '-dpng')

% ROMS u plot
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(2,2);

for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_uv.mat']);

    nexttile(5-pi); hold on; grid on

    pcolor(timenum_daily, z_model_daily, u_model_daily); shading interp
    ylim([-50 0])
    colormap redblue
    xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
    datetick('x', 'mmm, yyyy', 'keepticks')
    ylabel('m');

    c = colorbar; 
    c.Title.String = 'cm/s';
    caxis([-80 80]);

    title([point_name])
end

t.TileSpacing = 'compact';
t.Padding = 'compact';
title(t, 'ROMS zonal velocity')

print('ROMS_vert_uvel', '-dpng')
