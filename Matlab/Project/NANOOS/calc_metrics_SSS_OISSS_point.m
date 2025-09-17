%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate SSS metrics of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'salt';
map = 'US_west';

gn = grd('NANOOS');
Fn = scatteredInterpolant(gn.lat_rho(:), gn.lon_rho(:), 0.*gn.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

datenum_start = datenum(2023,1,5);
datenum_end = datenum(2024,12,25);
timenum = datenum_start:4:datenum_end;

filepath_obs = '/data/jungjih/Observations/Satellite_SSS/OISSS/weekly/';

vari_obs_all = NaN([length(timenum), 32, 37]);
vari_NANOOS_all = NaN([length(timenum), 32, 37]);
vari_WCOFS_all = NaN([length(timenum), 32, 37]);
for di = 1:length(timenum)
    yyyymmdd = datestr(timenum(di), 'yyyy-mm-dd');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));
    dd = str2num(datestr(timenum(di), 'dd'));

    % Obs
    filename_obs = ['OISSS_L4_multimission_global_7d_v2.0_', yyyymmdd, '.nc'];
    file_obs = [filepath_obs, filename_obs];
    lat_obs = double(ncread(file_obs, 'latitude'));
    lon_obs = double(ncread(file_obs, 'longitude'));
    vari_obs_tmp = squeeze(ncread(file_obs, 'sss'));
    index1 = find(lon_obs<0);
    index2 = find(lon_obs>0);
    lon_obs = [lon_obs(index2)-360; lon_obs(index1)];
    vari_obs_tmp = [vari_obs_tmp(index2,:); vari_obs_tmp(index1,:)];

    [lon_limit, lat_limit] = load_domain(map);
    lonind = find(lon_obs > min(lon_limit) & lon_obs < max(lon_limit));
    latind = find(lat_obs > min(lat_limit) & lat_obs < max(lat_limit));

    [lat_obs2, lon_obs2] = meshgrid(lat_obs(latind), lon_obs(lonind));
    vari_obs = vari_obs_tmp(lonind, latind);
    vari_obs_all(di,:,:) = vari_obs;

    % NANOOS
    vari_NANOOS = load_models_surf_weekly('NANOOS', vari_str, yyyy, mm, dd);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs2, lon_obs2);
    vari_NANOOS_all(di,:,:) = vari_NANOOS_interp;

    % WCOFS
    vari_WCOFS = load_models_surf_weekly('WCOFS', vari_str, yyyy, mm, dd);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs2, lon_obs2);
    vari_WCOFS_all(di,:,:) = vari_WCOFS_interp;

    disp([yyyymmdd, '...'])
end

vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;
vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;
tmp = vari_NANOOS_diff.*vari_WCOFS_diff;
index_common = find(isnan(tmp) == 0);

bias_NANOOS = [];
bias_WCOFS = [];
rmse_NANOOS = [];
rmse_WCOFS = [];
corrcoef_NANOOS = [];
corrcoef_WCOFS = [];
for i = 1:size(vari_obs_all,2)
    for j = 1:size(vari_obs_all,3)
        vari_obs_tmp = vari_obs_all(:,i,j);
        vari_NANOOS_tmp = vari_NANOOS_all(:,i,j);
        vari_WCOFS_tmp = vari_WCOFS_all(:,i,j);

        vari_NANOOS_diff = vari_NANOOS_tmp - vari_obs_tmp;
        vari_WCOFS_diff = vari_WCOFS_tmp - vari_obs_tmp;

        bias_NANOOS(i,j) = mean(vari_NANOOS_diff);
        bias_WCOFS(i,j) = mean(vari_WCOFS_diff);

        rmse_NANOOS(i,j) = sqrt( mean( vari_NANOOS_diff.^2 ) );
        rmse_WCOFS(i,j) = sqrt( mean( vari_WCOFS_diff.^2 ) );

        corrcoef_NANOOS_tmp = corrcoef(vari_obs_tmp, vari_NANOOS_tmp);
        corrcoef_NANOOS(i,j) = corrcoef_NANOOS_tmp(1,2);
        corrcoef_WCOFS_tmp = corrcoef(vari_obs_tmp, vari_WCOFS_tmp);
        corrcoef_WCOFS(i,j) = corrcoef_WCOFS_tmp(1,2);

    end
end

save(['metrics_SSS_OISSS_point.mat'], ...
    'index_common', 'lat_obs2', 'lon_obs2', ...
    'bias_NANOOS', 'bias_WCOFS', ...
    'rmse_NANOOS', 'rmse_WCOFS', ...
    'corrcoef_NANOOS', 'corrcoef_WCOFS')