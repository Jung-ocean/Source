%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate SST RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'temp';
map = 'US_west';

gn = grd('NANOOS');
Fn = scatteredInterpolant(gn.lat_rho(:), gn.lon_rho(:), 0.*gn.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

datenum_start = datenum(2023,1,1);
datenum_end = datenum(2024,12,31);
timenum = datenum_start:datenum_end;

filepath_obs = '/data/jungjih/Project/NANOOS/';
filename_obs = ['SST_buoy_daily.mat'];
file_obs = [filepath_obs, filename_obs];
data = load(file_obs);
timenum_obs = data.timenum;
timevec_obs = datevec(timenum_obs);
lat_obs = data.lats;
lon_obs = data.lons;
vari_obs_tmp = data.SST_daily;

for di = 1:length(timenum)
    yyyymmdd = datestr(timenum(di), 'yyyymmdd');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));
    dd = str2num(datestr(timenum(di), 'dd'));

    index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm & timevec_obs(:,3) == dd);
    vari_obs_mean(:,di) = mean(vari_obs_tmp(:,index), 'omitnan');

    % NANOOS diff
    vari_NANOOS = load_models_surf_daily('NANOOS', vari_str, yyyy, mm, dd);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs, lon_obs);
    vari_NANOOS_mean(:,di) = mean(vari_NANOOS_interp, 'omitnan');

    % WCOFS diff
    vari_WCOFS = load_models_surf_daily('WCOFS', vari_str, yyyy, mm, dd);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs, lon_obs);
    vari_WCOFS_mean(:,di) = mean(vari_WCOFS_interp, 'omitnan');

    disp([yyyymmdd, '...'])
end

corrcoef_tmp = corrcoef(vari_obs_mean, vari_NANOOS_mean);
corrcoef_NANOOS = corrcoef_tmp(1,2);
corrcoef_tmp = corrcoef(vari_obs_mean, vari_WCOFS_mean);
corrcoef_WCOFS = corrcoef_tmp(1,2);

vari_NANOOS_diff = vari_NANOOS_mean - vari_obs_mean;
index = find(isnan(vari_NANOOS_diff) == 0);
bias_NANOOS = mean(vari_NANOOS_diff(index));
rmse_NANOOS = sqrt( mean( vari_NANOOS_diff(index).^2 ) );

vari_WCOFS_diff = vari_WCOFS_mean - vari_obs_mean;
index = find(isnan(vari_WCOFS_diff) == 0);
bias_WCOFS = mean(vari_WCOFS_diff(index));
rmse_WCOFS = sqrt( mean( vari_WCOFS_diff(index).^2 ) );

save(['rmse_SST_buoy.mat'], 'timenum', ...
    'vari_obs_mean', 'vari_NANOOS_mean', 'vari_WCOFS_mean', ...
    'corrcoef_NANOOS', 'corrcoef_WCOFS', ...
    'bias_NANOOS', 'bias_WCOFS', ...
    'rmse_NANOOS', 'rmse_WCOFS');