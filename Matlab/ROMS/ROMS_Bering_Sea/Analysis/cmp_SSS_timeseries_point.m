%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SSS time series among mooring, model, satellite SSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

si = 4;

datenum_start = datenum(2010,1,1);
datenum_end = datenum(2024,12,31);

stations = {'bs2', 'bs4', 'bs5', 'bs8'};
names = {'M2', 'M4', 'M5', 'M8'};

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% M5 station
filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';
load([filepath_obs, 'ts_1h_', stations{si}, '.mat']);

lon_target = mean(lon_obs(:), 'omitnan');
lat_target = mean(lat_obs(:), 'omitnan');

depth_obs = 20;
dindex = find(depth_1m < depth_obs);
so = mean(salt_obs_1h(dindex,:), 1, 'omitnan');
pobs = plot(timenum_1h, so, 'Color', [0.4667 0.6745 0.1882], 'LineWidth', 2);

% Model
vari_str = 'salt';
layer = 45;
if ~exist(['SSS_ROMS_', names{si}, '.mat'])
    [tm,sm] = load_BSf_3d(vari_str, layer, datenum(2019,1,1), datenum(2023,12,31), lat_target, lon_target);
    save(['SSS_ROMS_', names{si}, '.mat'], 'tm', 'sm')
else
    load(['SSS_ROMS_', names{si}, '.mat'])
end
pmodel = plot(tm, sm, 'k', 'LineWidth', 2);

% SMAP
if ~exist(['SSS_SMAP_', names{si}, '.mat'])
    [tsmap, ssmap] = load_SSS_sat('SMAP', datenum(2015,1,1), datenum(2024,12,31), lat_target, lon_target);
    save(['SSS_SMAP_', names{si}, '.mat'], 'tsmap', 'ssmap')
else
    load(['SSS_SMAP_', names{si}, '.mat'])
end
psmap = plot(tsmap, ssmap ,'.r');

% SMOS
if ~exist(['SSS_SMOS_', names{si}, '.mat'])
    [tsmos, ssmos] = load_SSS_sat('SMOS', datenum(2010,1,1), datenum(2023,12,31), lat_target, lon_target);
    save(['SSS_SMOS_', names{si}, '.mat'], 'tsmos', 'ssmos')
else
    load(['SSS_SMOS_', names{si}, '.mat'])
end
psmos = plot(tsmos, ssmos, '.b');

uistack(pmodel, 'top')
% uistack(pobs, 'top')

xlim([datenum_start-1 datenum_end+1])
ylim([28 34])
xticks(datenum(2010:2023,1,1))
datetick('x', 'yyyy', 'keeplimits', 'keeplimits')
ylabel('psu')

set(gca, 'FontSize', 12)

l = legend([pobs, pmodel, psmap, psmos], ['Mooring (top ', num2str(depth_obs), ' m)'], 'ROMS', 'SMAP', 'SMOS');
l.Location = 'SouthWest';
l.NumColumns = 4;
l.FontSize = 15;

title(['SSS at ', names{si}])

print(['cmp_SSS_timeseries_', names{si}], '-dpng')