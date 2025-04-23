%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot timeline of available data using Bering Sea mooring data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

g = grd('BSf');

stations = {'bs2', 'bs4', 'bs5', 'bs8'};
names = {'M2', 'M4', 'M5', 'M8'};

figure(1); hold on;
set(gcf, 'Position', [1 200 800 500]);
plot_map('Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200 1000], 'k')

figure(2);
set(gcf, 'Position', [1 200 800 800]);
t2 = tiledlayout(4,1);
title(t2, 'Timeline of available uv', 'FontSize', 15)

figure(3);
set(gcf, 'Position', [1 200 800 800]);
t3 = tiledlayout(4,1);
title(t3, 'Timeline of available T (blue) and S (red)', 'FontSize', 15)

for si = 1:length(stations)
    station = stations{si};
    file_uv = ['uv_1h_', station, '.mat'];
    load(file_uv)
     
    figure(1)
    plotm(mean(lat_obs(:), 'omitnan'), mean(lon_obs(:), 'omitnan'), '.r', 'MarkerSize', 20)
    textm(mean(lat_obs(:)+.7, 'omitnan'), mean(lon_obs(:)-2, 'omitnan'), names{si}, 'Color', 'r', 'FontSize', 20)
    
    figure(2); nexttile(5-si); hold on; grid on;
    for i = 1:size(u_obs_1h,1)
        u_obs_1h_tmp = u_obs_1h(i,:);
        index = find(isnan(u_obs_1h_tmp) == 0);
        timenum_tmp = timenum_1h(index);
        plot(timenum_tmp, -ones(size(timenum_tmp)).*depth_1m(i), '.', 'Color', [.5 .5 .5], 'MarkerSize', 3);
    end
    for i = 1:size(v_obs_1h,1)
        v_obs_1h_tmp = v_obs_1h(i,:);
        index = find(isnan(v_obs_1h_tmp) == 0);
        timenum_tmp = timenum_1h(index);
        plot(timenum_tmp, -ones(size(timenum_tmp)).*depth_1m(i), '.k', 'MarkerSize', 3);
    end
    xticks([datenum(2016:2025,1,1)])
    xlim([datenum(2016,1,1) datenum(2025, 1, 1)])
    datetick('x', 'yyyy', 'keepticks', 'keeplimits')
    ylim([-80 0])
    ylabel('depth (m)')
    title(names{si})
    set(gca, 'FontSize', 12)

    file_ts = ['ts_1h_', station, '.mat'];
    load(file_ts)
    figure(3); nexttile(5-si); hold on; grid on;
    for i = 1:size(temp_obs_1h,1)
        temp_obs_1h_tmp = temp_obs_1h(i,:);
        index = find(isnan(temp_obs_1h_tmp) == 0);
        timenum_tmp = timenum_1h(index);
        plot(timenum_tmp, -ones(size(timenum_tmp)).*depth_1m(i), '.b', 'MarkerSize', 3);
    end
    for i = 1:size(salt_obs_1h,1)
        salt_obs_1h_tmp = salt_obs_1h(i,:);
        index = find(isnan(salt_obs_1h_tmp) == 0);
        timenum_tmp = timenum_1h(index);
        plot(timenum_tmp, -ones(size(timenum_tmp)).*depth_1m(i), '.r', 'MarkerSize', 1.5);
    end
    
    xticks([datenum(2016:2025,1,1)])
    xlim([datenum(2016,1,1) datenum(2025, 1, 1)])
    datetick('x', 'yyyy', 'keepticks', 'keeplimits')
    ylim([-80 0])
    ylabel('depth (m)')
    title(names{si})
    set(gca, 'FontSize', 12)
end

figure(1)
print('map_BSm', '-dpng')

figure(2)
print('timeline_available_uv', '-dpng')

figure(3)
print('timeline_available_TS', '-dpng')