%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SSS time series among mooring, model, satellite SSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

si = 4;

datenum_start = datenum(2020,1,1);
dsstr = datestr(datenum_start, 'yyyymmdd');
datenum_end = datenum(2022,12,31);
destr = datestr(datenum_end, 'yyyymmdd');

stations = {'bs2', 'bs4', 'bs5', 'bs8'};
names = {'M2', 'M4', 'M5', 'M8'};

g = grd('BSf');

% Bering Sea mooring station
filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';
load([filepath_obs, 'ts_1h_', stations{si}, '.mat']);

lon_target = mean(lon_obs(:), 'omitnan');
lat_target = mean(lat_obs(:), 'omitnan');

figure; hold on; grid on;
t = tiledlayout(1,3);
set(gcf, 'Position', [1 200 1300 500])

% Map
nexttile(1);
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
plotm(lat_target, lon_target, '.r', 'MarkerSize', 40);
textm(lat_target+.5, lon_target-2.3, names{si}, 'Color', 'r', 'FontSize', 20);

% Plot
nexttile(2,[1 2]); hold on; grid on;
depth_obs = 20;
dindex = find(depth_1m < depth_obs);
so = mean(salt_obs_1h(dindex,:), 1, 'omitnan');
pobs = plot(timenum_1h, so, 'Color', [0.4941 0.1843 0.5569], 'LineWidth', 2);

% Model
vari_str = 'salt';
layer = 45;
filename_ROMS = ['SSS_ROMS_', names{si}, '_', dsstr, '_', destr, '.mat'];
if ~exist(filename_ROMS)
    [tm,sm] = load_BSf_1d(g, vari_str, layer, datenum_start, datenum_end, lat_target, lon_target);
    save(filename_ROMS, 'tm', 'sm')
else
    load(filename_ROMS)
end
pmodel = plot(tm, sm, 'k', 'LineWidth', 2);

% SMAP
filename_SMAP = ['SSS_SMAP_', names{si}, '_', dsstr, '_', destr, '.mat'];
if ~exist(filename_SMAP)
    [tsmap, ssmap] = load_SSS_sat_1d('SMAP', 6, datenum_start, datenum_end, lat_target, lon_target);
    save(filename_SMAP, 'tsmap', 'ssmap')
else
    load(filename_SMAP)
end
psmap = plot(tsmap, ssmap ,'.r');

% SMOS
filename_SMOS = ['SSS_SMOS_', names{si}, '_', dsstr, '_', destr, '.mat'];
if ~exist(filename_SMOS)
    [tsmos, ssmos] = load_SSS_sat_1d('SMOS', 10, datenum_start, datenum_end, lat_target, lon_target);
    save(filename_SMOS, 'tsmos', 'ssmos')
else
    load(filename_SMOS)
end
psmos = plot(tsmos, ssmos, '.b');

% CMEMS
filename_CMEMS = ['SSS_CMEMS_', names{si}, '_', dsstr, '_', destr, '.mat'];
if ~exist(filename_CMEMS)
    [tcmems, scmems] = load_SSS_sat_1d('CMEMS', 0, datenum_start, datenum_end, lat_target, lon_target);
    save(filename_CMEMS, 'tcmems', 'scmems')
else
    load(filename_CMEMS)
end
pcmems = plot(tcmems, scmems, '.g');

% SMOS_BEC
filename_SMOS_BEC = ['SSS_SMOS_BEC_', names{si}, '_', dsstr, '_', destr, '.mat'];
if ~exist(filename_SMOS_BEC)
    [tsmos_bec, ssmos_bec] = load_SSS_sat_1d('SMOS_BEC', 4, datenum_start, datenum_end, lat_target, lon_target);
    save(filename_SMOS_BEC, 'tsmos_bec', 'ssmos_bec')
else
    load(filename_SMOS_BEC)
end
psmos_bec = plot(tsmos_bec, ssmos_bec, '.m');

uistack(pobs, 'top')
% uistack(pobs, 'top')

xlim([datenum_start-1 datenum_end+1])
ylim([28 34])
xticks(datenum(2010:2025,1,1))
datetick('x', 'yyyy', 'keeplimits', 'keeplimits')
ylabel('psu')

set(gca, 'FontSize', 12)

l = legend([pobs, pmodel, psmap, psmos], ['Mooring (top ', num2str(depth_obs), ' m)'], 'ROMS', 'SMAP', 'SMOS');
l.Location = 'SouthWest';
l.NumColumns = 4;
l.FontSize = 15;

title(['SSS at ', names{si}])
asdfasdf
print(['cmp_SSS_timeseries_', names{si}], '-dpng')