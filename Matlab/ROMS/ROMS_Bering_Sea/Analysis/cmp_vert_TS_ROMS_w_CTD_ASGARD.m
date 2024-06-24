%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical TS to CTD ASGARD data
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
filepath_obs = '/data/jungjih/Observations/CTD/ASGARD/';
load([filepath_obs, 'CTD_ASGARD.mat'])

for pi = 1:length(points)

    point = points(pi);
    point_name = points_name{point};
    point_location = points_location(point,:);
    point_lat = point_location(1);
    point_lon = point_location(2);

    dist = sqrt((g.lon_rho - point_lon).^2 + abs(g.lat_rho - point_lat).^2);
    [latind, lonind] = find(dist == min(dist(:)));

    if exist([point_name, '_vert_TS.mat']) == 0

        findex_all = [];
        for i = 1:length(CTD)
            filename_tmp = CTD(i).filename;
            if strcmp(filename_tmp(11:12), point_name)
                findex_all = [findex_all; i];
            end
        end


        data = [];
        ci = 1;
        for fi = 1:length(findex_all)
            findex = findex_all(fi);

            timenum = CTD(findex).timenum;
            depth = CTD(findex).depth;
            temp = CTD(findex).temp;
            salt = CTD(findex).salt;

            timenum_daily = period;
            temp_model_daily = [];
            salt_model_daily = [];
            temp_obs_daily = [];
            salt_obs_daily = [];
            for ti = 1:length(timenum_daily)
                tindex = find(floor(timenum) == timenum_daily(ti));

                timenum_target = timenum(tindex);
                temp_target = temp(tindex);
                salt_target = salt(tindex);

                if isempty(tindex) ~= 1
                    temp_obs_daily(ti) = mean(temp_target);
                    salt_obs_daily(ti) = mean(salt_target);
                else
                    temp_obs_daily(ti) = NaN;
                    salt_obs_daily(ti) = NaN;
                end

                filenumber = timenum_daily(ti) - startdate + 1;
                fstr = num2str(filenumber, '%04i');
                filename = ['Dsm2_spng_avg_', fstr, '.nc'];
                file = [filepath, filename];

                if exist(file) ~= 0
%                     temp = ncread(file, 'temp'); temp = permute(temp, [3 2 1]);
%                     salt = ncread(file, 'salt'); salt = permute(salt, [3 2 1]);
%                     temp_point = temp(:, latind, lonind);
%                     salt_point = salt(:, latind, lonind);
                  
                    temp_point = squeeze(ncread(file, 'temp', [lonind latind 1 1], [1 1 Inf Inf]));
                    salt_point = squeeze(ncread(file, 'salt', [lonind latind 1 1], [1 1 Inf Inf]));
                    z_point = g.z_r(:,latind, lonind);
                    
                    if depth > g.h(latind, lonind)
                        temp_model_daily(ti) = temp_point(1);
                        salt_model_daily(ti) = salt_point(1);
                    else
                        temp_model_daily(ti) = interp1(z_point, temp_point, -depth);
                        salt_model_daily(ti) = interp1(z_point, salt_point, -depth);
                    end

                else
                    temp_model_daily(ti) = NaN;
                    salt_model_daily(ti) = NaN;
                end

                disp([num2str(fi), '/', num2str(length(findex_all)),' ', datestr(timenum_daily(ti), 'yyyymmdd')])
            end % ti

            data(ci).timenum_daily = timenum_daily;
            data(ci).depth = depth;
            data(ci).temp_obs_daily = temp_obs_daily;
            data(ci).salt_obs_daily = salt_obs_daily;
            data(ci).temp_model_daily = temp_model_daily;
            data(ci).salt_model_daily = salt_model_daily;

            ci = ci+1;
        end % fi

        save([point_name, '_vert_TS.mat'], 'data');
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

% CTD temp plot
for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_TS.mat']);
    
    f1 = figure; hold on; grid on;
    set(gcf, 'Position', [1 200 800 500])
    pause(1)
    for di = 1:length(data)
        pmodel = plot(data(di).timenum_daily, data(di).temp_model_daily, 'Color', [0    0.4471    0.7412]);
        pobs = plot(data(di).timenum_daily, data(di).temp_obs_daily, 'Color', [0.8510    0.3255    0.0980]);

        ylim([-2 15])
        xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
        datetick('x', 'mmm, yyyy', 'keepticks')
        ylabel('^oC');

        l = legend([pmodel, pobs], 'ROMS', 'CTD');
        l.Location = 'NorthWest';
        l.FontSize = 15;

        title([point_name, ' (', num2str(data(di).depth), ' m) temperature'])

        print(['cmp_vert_temp_w_CTD_', point_name, '_', num2str(data(di).depth), 'm'], '-dpng')

        delete(pobs); delete(pmodel)
    end
end

% CTD salt plot
for pi = 1:length(points)
    point = points(pi);
    point_name = points_name{point};
    load([point_name, '_vert_TS.mat']);
    
    f1 = figure; hold on; grid on;
    set(gcf, 'Position', [1 200 800 500])
    pause(1)
    for di = 1:length(data)

        index = find(data(di).salt_model_daily < 20);
        data(di).salt_model_daily(index) = NaN;

        pmodel = plot(data(di).timenum_daily, data(di).salt_model_daily, 'Color', [0    0.4471    0.7412]);
        pobs = plot(data(di).timenum_daily, data(di).salt_obs_daily, 'Color', [0.8510    0.3255    0.0980]);

        ylim([29 33])
        xticks([datenum(2017,6:12,1), datenum(2018,1:12,1) datenum(2019,1:8,1)])
        datetick('x', 'mmm, yyyy', 'keepticks')
        ylabel('^oC');

        l = legend([pmodel, pobs], 'ROMS', 'CTD');
        l.Location = 'SouthWest';
        l.FontSize = 15;

        title([point_name, ' (', num2str(data(di).depth), ' m) salinity'])

        print(['cmp_vert_salt_w_CTD_', point_name, '_', num2str(data(di).depth), 'm'], '-dpng')

        delete(pobs); delete(pmodel)
    end
end

