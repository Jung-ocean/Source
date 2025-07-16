%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare SSS time series among mooring, model, satellite SSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

g = grd('BSf');

datenum_start = datenum(2010,1,1);
datenum_end = datenum(2024,12,31);

% figure;
% contour(g.lon_rho, g.lat_rho, g.h, [100 200 1000], '-k');
% [x,y] = ginput;
% lon_target = x;
% lat_target = y;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])

% Model
vari_str = 'salt';
layer = 45;
if ~exist(['SSS_ROMS.mat'])
    [tm,sm] = load_BSf_3d(g, vari_str, layer, datenum(2019,1,1), datenum(2023,12,31), lat_target, lon_target);
    save(['SSS_ROMS.mat'], 'tm', 'sm')
else
    load(['SSS_ROMS_', names{si}, '.mat'])
end
pmodel = plot(tm, sm, 'k', 'LineWidth', 2);

% SMAP
if ~exist(['SSS_SMAP.mat'])
    [tsmap, ssmap] = load_SSS_sat('SMAP', datenum(2015,1,1), datenum(2024,12,31), lat_target, lon_target);
    save(['SSS_SMAP.mat'], 'tsmap', 'ssmap')
else
    load(['SSS_SMAP.mat'])
end
psmap = plot(tsmap, ssmap ,'.r');

% SMOS
if ~exist(['SSS_SMOS.mat'])
    [tsmos, ssmos] = load_SSS_sat('SMOS', datenum(2010,1,1), datenum(2023,12,31), lat_target, lon_target);
    save(['SSS_SMOS.mat'], 'tsmos', 'ssmos')
else
    load(['SSS_SMOS.mat'])
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

% print(['cmp_SSS_timeseries_', names{si}], '-dpng')