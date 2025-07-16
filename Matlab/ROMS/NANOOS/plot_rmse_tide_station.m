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
datenum_start = datenum(yyyy,9,1);
datenum_end = datenum(yyyy,12,31);

load(['rmse_tide_station_', datestr(datenum_start, 'yyyymmdd'), '_', datestr(datenum_end, 'yyyymmdd'), '.mat'])

figure;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,5);
title(t, ['Tide complex RMSE (NOAA station) ', datestr(datenum_start, 'mmm dd, yyyy'), ' - ', datestr(datenum_end, 'mmm dd, yyyy'),], 'FontSize', 15)

for ci = 1:length(constituents)
    nexttile(ci); hold on; grid on;

    pn = plot(rmse_NANOOS(:,ci), lats, '.-k', 'LineWidth', 2, 'MarkerSize', 20);
    pw = plot(rmse_WCOFS(:,ci), lats, '.-r', 'LineWidth', 2, 'MarkerSize', 20);

    xlim([0 0.6])
    xticks([0:.2:0.6])
    xlabel('m')
    yticks(lats)
    if ci == 1
        yticklabels(num2str(lats, '%.1f'));
        ylabel('Latitude')
        l = legend([pn, pw], 'NANOOS', 'WCOFS');
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
si = 4;
id = ids(si);
idstr = num2str(id);
obs = readtable(['/data/jungjih/Observations/NOAA_stations/US_west/WL_', idstr, '_', ystr, '.csv']);

obs_yyyymmdd = datenum(table2array(obs(:,1)), 'yyyy/mm/dd');
obs_HHMM = datenum(table2array(obs(:,2)), 'HH:MM') - floor(datenum(table2array(obs(:,2)), 'HH:MM'));
timenum_obs = obs_yyyymmdd + obs_HHMM;
vari_obs = table2array(obs(:,5));

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum_NANOOS, vari_NANOOS(si,:), '-k', 'LineWidth', 1);
pw = plot(timenum_WCOFS, vari_WCOFS(si,:), '-r', 'LineWidth', 1);
po = plot(timenum_obs, vari_obs, '-g');

xlim([datenum_start datenum_end])
ylim([-4 4])

xticks(datenum(yyyy,1:12,1));
datetick('x', 'mmm dd, yyyy', 'keepticks', 'keeplimits')
ylabel('Sea level (m)')
set(gca, 'FontSize', 12)

l = legend([pn, pw, po], 'OSU ROMS', 'WCOFS', 'Observation');
l.Location = 'NorthWest';
l.FontSize = 15;

title(stations{si}, 'FontSize', 15)

print(['timeseries_tide_station_', stations{si}, '_', ystr], '-dpng')