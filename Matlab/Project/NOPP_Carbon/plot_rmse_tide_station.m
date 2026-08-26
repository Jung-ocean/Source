%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot tide RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2024;
ystr = num2str(yyyy);
datenum_start = datenum(yyyy,1,1);
datenum_end = datenum(yyyy,11,30);

load(['rmse_tide_station_', datestr(datenum_start, 'yyyymmdd'), '_', datestr(datenum_end, 'yyyymmdd'), '.mat'])

figure;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,4);
title(t, ['Tide complex RMSE (NOAA station) ', datestr(datenum_start, 'mmm dd, yyyy'), ' - ', datestr(datenum_end, 'mmm dd, yyyy'),], 'FontSize', 15)

for ci = 1:length(constituents)
    nexttile(ci); hold on; grid on;

    pn = plot(rmse_ROMS(:,ci), lats, '.-k', 'LineWidth', 2, 'MarkerSize', 20);

    xlim([0 0.4])
    xticks([0:.2:0.4])
    xlabel('m')
    yticks(lats)
    if ci == 1
        yticklabels(num2str(lats, '%.1f'));
        ylabel('Latitude')
        l.Location = 'SouthEast';
        l.FontSize = 12;
    elseif ci == length(constituents)
        set(gca ,'YAxisLocation', 'right')
        yticklabels(stations);
    else
        yticklabels('');
    end
    set(gca ,'FontSize', 12)

    title(constituents{ci}, 'FontSize', 15)
end

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['rmse_tide_station_', ystr], '-dpng')

% Timeseries
for si = 1:length(stations)

    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 1300 500])
    pn = plot(timenum_ROMS, vari_ROMS(si,:), '-k', 'LineWidth', 2);
    po = plot(timenum_obs, vari_obs(si,:), '--r', 'LineWidth', 2);

    xlim([datenum_end-60 datenum_end-29])
    ylim([-2.2 2.2])

    xticks(datenum(yyyy,1:12,1));
    datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
    ylabel('Sea level (m)')
    set(gca, 'FontSize', 12)

    l = legend([pn, po], 'ROMS', 'Observation');
    l.Location = 'SouthOutside';
    l.NumColumns = 2;
    l.FontSize = 15;

    title(stations{si}, 'FontSize', 15)

    print(['timeseries_tide_station_', stations{si}, '_', ystr], '-dpng')

end