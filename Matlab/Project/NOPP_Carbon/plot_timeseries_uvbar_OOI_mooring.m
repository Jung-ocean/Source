%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot depth-averaged current timeseries of the ROMS model using OOI mooring
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

domain = 'Oregon_1km';
expname = 'LiveOcean_rad_out';
cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

yyyy = 2024;
ystr = num2str(yyyy);

timenum_obs = datenum(yyyy,1,1):datenum(yyyy,12,31);

vari_str = 'vbar';
vari_str_obs = [vari_str(1), 'vel'];
vari_model = vari_str(1);
regions_target = 'WA_shelf';
ismap = 0;

switch regions_target
    case 'WA_shelf'
        h_obs = 87;
        lon_obs = -124.566;
        lat_obs = 46.9859;
    case 'OR_shelf'
        h_obs = 80;
        lon_obs = -124.304;
        lat_obs = 44.6393;
end

depth_target = -10:-1:-(h_obs-10); % should be negative
dstr1 = num2str(abs(depth_target(1)));
dstr2 = num2str(abs(depth_target(end)));

g = grd(domain);

if ismap == 1
    % Map
    ismap = 1;
    figure;
    set(gcf, 'Position', [1 200 500 800])
    plot_map(domain, 'mercator', 'l');
    [cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');
    cl = clabelm(cs, h);
    set(cl, 'BackgroundColor', 'none');
    plotm(lat_obs, lon_obs, 'xr', 'MarkerSize', 12, 'LineWidth', 4);
    print(['map_OOI_mooring_', regions_target], '-dpng')
end

data = load_OOI_mooring_uv_daily(regions_target, vari_str_obs, timenum_obs, depth_target);
vari_obs1 = 100*data(1).vari; % m/s to cm/s
vari_obs2 = 100*data(2).vari; % m/s to cm/s
vari_cat = cat(3,vari_obs1,vari_obs2);
vari_obs_tmp = mean(vari_cat,3,'omitnan');
vari_obs = mean(vari_obs_tmp,1,'omitnan');

mask = vari_obs_tmp./vari_obs_tmp;
vari_obs_isnan = isnan(vari_obs);
index = find(vari_obs_isnan == 1);
mask(:,index) = 1;

if strcmp(vari_str, 'ubar')
    title_str = ['Depth-averaged zonal current (daily)'];
else
    title_str = ['Depth-averaged meridional current (daily)'];
end

file_models = ['uvbar_ROMS_', regions_target, '.mat'];
if exist(file_models)
    load(file_models)
else
    u_ROMS_tmp = [];
    v_ROMS_tmp = [];
    for ti = 1:length(timenum_obs)
        timenum_target = timenum_obs(ti);
        profile = load_models_uv_profile_daily('Oregon_1km', expname, g, timenum_target, lon_obs, lat_obs, h_obs);
        u_tmp = profile.u;
        u_interp = interp1(profile.z_r, u_tmp, depth_target);
        u_ROMS_tmp(:,ti) = 100*u_interp; % m/s to cm/s
        v_tmp = profile.v;
        v_interp = interp1(profile.z_r, v_tmp, depth_target);
        v_ROMS_tmp(:,ti) = 100*v_interp; % m/s to cm/s
    end
    u_ROMS_tmp2 = u_ROMS_tmp.*mask;
    ubar_ROMS = mean(u_ROMS_tmp2, 1, 'omitnan');
    v_ROMS_tmp2 = v_ROMS_tmp.*mask;
    vbar_ROMS = mean(v_ROMS_tmp2, 1, 'omitnan');
    
    save(file_models, 'timenum_obs', 'lon_obs', 'lat_obs', 'h_obs', 'depth_target', 'ubar_ROMS', 'vbar_ROMS')
end

vari_ROMS = eval([vari_str, '_ROMS']);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
pn = plot(timenum_obs, vari_ROMS, '-k', 'LineWidth', 2);
po = plot(timenum_obs, vari_obs, '-r', 'LineWidth', 2);

ylim([-55 55])

xticks([datenum(2024,1:12,1)])
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
ylabel('cm/s')

set(gca, 'FontSize', 12)

index = find(isnan(vari_obs) ~= 1);
vari_obs_data = vari_obs(index);
vari_ROMS_data = vari_ROMS(index);

% corrcoef_tmp = corrcoef(vari_obs_data, vari_ROMS_data, 'row', 'complete');
% corrcoef_ROMS = corrcoef_tmp(1,2);
[R, P, P_ess, ESS] = calc_ess_and_pvalue(vari_obs_data',vari_ROMS_data');
corrcoef_ROMS = R;

vari_ROMS_diff = vari_ROMS_data - vari_obs_data;
index = find(isnan(vari_ROMS_diff) == 0);
bias_ROMS = mean(vari_ROMS_diff(index));
rmse_ROMS = sqrt( mean( vari_ROMS_diff(index).^2 ) );

l = legend([pn, po], ...
    ['ROMS (', ... 
    'bias = ', num2str(bias_ROMS, '%.2f'), ' cm/s, ', ...
    'RMSE = ', num2str(rmse_ROMS, '%.2f'), ' cm/s, ', ...
    'r = ', num2str(corrcoef_ROMS, '%.2f'), ')'], ...
    ['Observation (', replace(regions_target, '_', ' '), ')']);
l.Location = 'SouthEast';
l.FontSize = 15;

title(title_str)
box on

print(['timeseries_', vari_str, '_OOI_', regions_target], '-dpng')