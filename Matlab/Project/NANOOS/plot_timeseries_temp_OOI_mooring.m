%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot current timeseries of NANOOS and WCOFS models using OOI mooring
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'temp';
vari_model = vari_str;
regions_target = 'OR_shelf';
depth_tmp = -10; % should be negative

ismap = 0;

gn = grd('NANOOS');
gw = grd('WCOFS');

load_OOI_mooring_info
rindex = find(strcmp(regions, regions_target));
lat_obs = lats(rindex);
lon_obs = lons(rindex);

if ismap == 1
    % Map
    figure;
    set(gcf, 'Position', [1 200 500 800])
    plot_map('US_west', 'mercator', 'l');
    [cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');
    plotm(lat_obs, lon_obs, 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
    print(['location_OOI_mooring_', regions_target], '-dpng')
end

load([vari_str, '_', regions_target, '_daily.mat'])
dist = abs(depth - depth_tmp);
index = find(dist == min(dist));
depth_target = depth(index);
vari_obs = vari(index,:);

dstr = num2str(-depth_target);
if strcmp(vari_str, 'uvel')
    title_str = [dstr, ' m zonal current (daily)'];
else
    title_str = [dstr, ' m meridional current (daily)'];
end

file_models = [vari_str, '_', regions_target, '_daily_models_', dstr, 'm.mat'];
if exist(file_models)
    load(file_models)
else
    vari_NANOOS = [];
    vari_WCOFS = [];
    for ti = 1:length(timenum)
        timenum_target = timenum(ti);
        vari_NANOOS(ti) = load_models_profile_daily('NANOOS', gn, vari_model, timenum_target, lat_obs, lon_obs, depth_target);
        vari_WCOFS(ti) = load_models_profile_daily('WCOFS', gw, vari_model, timenum_target, lat_obs, lon_obs, depth_target);
    end
    save(file_models, 'timenum', 'depth_target', 'vari_NANOOS', 'vari_WCOFS')
end

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum, vari_NANOOS, '-k', 'LineWidth', 2);
pw = plot(timenum, vari_WCOFS, '-r', 'LineWidth', 2);
po = plot(timenum, vari_obs, '-g', 'LineWidth', 2);

plot([datenum(2024,1,1) datenum(2024,1,1)], [-110 110], '-k')
text(datenum(2023,11,15), 33.5, '2023', 'FontSize', 15)
text(datenum(2024,11,15), 33.5, '2024', 'FontSize', 15)

xlim([datenum(2023,1,1)-1 datenum(2024,12,31)+1])
ylim([0 14])

xticks([datenum(2023,1:12,1) datenum(2024,1:12,1)])
datetick('x', 'm', 'keepticks', 'keeplimits')
ylabel('psu')

set(gca, 'FontSize', 12)

index = find(isnan(vari_obs) ~= 1);
vari_obs_data = vari_obs(index);
vari_NANOOS_data = vari_NANOOS(index);
vari_WCOFS_data = vari_WCOFS(index);

corrcoef_tmp = corrcoef(vari_obs_data, vari_NANOOS_data, 'row', 'complete');
corrcoef_NANOOS = corrcoef_tmp(1,2);
corrcoef_tmp = corrcoef(vari_obs_data, vari_WCOFS_data, 'row', 'complete');
corrcoef_WCOFS = corrcoef_tmp(1,2);

vari_NANOOS_diff = vari_NANOOS_data - vari_obs_data;
index = find(isnan(vari_NANOOS_diff) == 0);
bias_NANOOS = mean(vari_NANOOS_diff(index));
rmse_NANOOS = sqrt( mean( vari_NANOOS_diff(index).^2 ) );

vari_WCOFS_diff = vari_WCOFS_data - vari_obs_data;
index = find(isnan(vari_WCOFS_diff) == 0);
bias_WCOFS = mean(vari_WCOFS_diff(index));
rmse_WCOFS = sqrt( mean( vari_WCOFS_diff(index).^2 ) );

l = legend([pn, pw, po], ...
    ['OSU ROMS (', ... 
    'bias = ', num2str(bias_NANOOS, '%.2f'), ' cm/s, ', ...
    'RMSE = ', num2str(rmse_NANOOS, '%.2f'), ' cm/s, ', ...
    'corr coef = ', num2str(corrcoef_NANOOS, '%.2f'), ')'], ...
    ['WCOFS (', ...
    'bias = ', num2str(bias_WCOFS, '%.2f'), ' cm/s, ', ...
    'RMSE = ', num2str(rmse_WCOFS, '%.2f'), ' cm/s, ', ...
    'corr coef = ', num2str(corrcoef_WCOFS, '%.2f'), ')'], ...
    'Observation');
l.Location = 'SouthEast';
l.FontSize = 15;

title(title_str)
box on

print(['timeseries_', dstr, 'm_', vari_model, '_OOI_', regions_target], '-dpng')