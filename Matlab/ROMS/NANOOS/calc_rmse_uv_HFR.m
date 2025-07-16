%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate uv RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'v';
map = 'US_west';

g = grd('NANOOS');
Fn = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), 0.*g.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

datenum_start = datenum(2023,1,1);
datenum_end = datenum(2024,12,31);
timenum = datenum_start:datenum_end;

filepath_obs = '/data/jungjih/Observations/Surface_current/HFR/daily/';

for di = 1:length(timenum)
    yyyymmdd = datestr(timenum(di), 'yyyymmdd');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));
    dd = str2num(datestr(timenum(di), 'dd'));

    % Obs
    filename_obs = ['HFR_', yyyymmdd, '.nc'];
    file_obs = [filepath_obs, filename_obs];
    try
        lat_obs = double(ncread(file_obs, 'lat'));
        lon_obs = double(ncread(file_obs, 'lon'));
        vari_obs = double(ncread(file_obs, vari_str));
    catch
        disp('No such file')
        lat_obs = NaN;
        lon_obs = NaN;
        vari_obs = NaN;
    end
    vari_obs_mean(di,1) = mean(vari_obs, 'omitnan');
    mask = ~isnan(vari_obs)./~isnan(vari_obs);

    % NANOOS
    vari_NANOOS = 100.*load_models_surf_daily('NANOOS', vari_str, yyyy, mm, dd);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs, lon_obs);
    vari_NANOOS_mean(di,1) = mean(mask.*vari_NANOOS_interp, 'omitnan');

    % WCOFS
    vari_WCOFS = 100.*load_models_surf_daily('WCOFS', vari_str, yyyy, mm, dd);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs, lon_obs);
    vari_WCOFS_mean(di,1) = mean(mask.*vari_WCOFS_interp, 'omitnan');

    disp([yyyymmdd, '...'])
end

corrcoef_tmp = corrcoef(vari_obs_mean, vari_NANOOS_mean, 'row', 'complete');
corrcoef_NANOOS = corrcoef_tmp(1,2);
corrcoef_tmp = corrcoef(vari_obs_mean, vari_WCOFS_mean, 'row', 'complete');
corrcoef_WCOFS = corrcoef_tmp(1,2);

vari_NANOOS_diff = vari_NANOOS_mean - vari_obs_mean;
index = find(isnan(vari_NANOOS_diff) == 0);
bias_NANOOS = mean(vari_NANOOS_diff(index));
rmse_NANOOS = sqrt( mean( vari_NANOOS_diff(index).^2 ) );

vari_WCOFS_diff = vari_WCOFS_mean - vari_obs_mean;
index = find(isnan(vari_WCOFS_diff) == 0);
bias_WCOFS = mean(vari_WCOFS_diff(index));
rmse_WCOFS = sqrt( mean( vari_WCOFS_diff(index).^2 ) );

save(['rmse_surf_', vari_str, '_HFR.mat'], 'timenum', ...
    'vari_obs_mean', 'vari_NANOOS_mean', 'vari_WCOFS_mean', ...
    'corrcoef_NANOOS', 'corrcoef_WCOFS', ...
    'bias_NANOOS', 'bias_WCOFS', ...
    'rmse_NANOOS', 'rmse_WCOFS');