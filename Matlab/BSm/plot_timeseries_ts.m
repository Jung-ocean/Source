%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot time series of temperature and salinity using Bering Sea mooring data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

stations = {'bs2', 'bs4', 'bs5', 'bs8'};
names = {'M2', 'M4', 'M5', 'M8'};

color = flipud(jet);

for si = 1:length(stations)
    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 1300 500])
    t = tiledlayout(2,1);

    station = stations{si};

    load(['ts_1h_', station, '.mat']);

    for i = 1:2
        nexttile(i); hold on; grid on
        if i == 1
            for di = 1:length(depth_1m)
                plot(timenum_1h, temp_obs_1h(di,:), 'Color', color(round(di*length(color)/length(depth_1m)), :))
                ylim([-5 15])
                ylabel('^oC')
                set(gca, 'FontSize', 12)
                title('temp')
            end
        else
            for di = 1:length(depth_1m)
                plot(timenum_1h, salt_obs_1h(di,:), 'Color', color(round(di*length(color)/length(depth_1m)), :))
                ylim([28 34])
                ylabel('psu')
                set(gca, 'FontSize', 12)
                title('salt')
            end
        end

        xticks(datenum(2016:2025,1,1))
        datetick('x', 'mmm, yyyy', 'keepticks')

        title(t, names{si})
    end
    colormap(color)
    c = colorbar;
    set(c, 'YDir', 'reverse' );
    c.Layout.Tile = 'East';
    c.Ticks = [0 1];
    c.TickLabels = {'0 m', [num2str(length(depth_1m)), ' m']};

    print(['timeseries_ts_', names{si}], '-dpng')
end