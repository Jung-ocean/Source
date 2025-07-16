%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate SST RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

si = 2;

vari_str = 'temp';
map = 'US_west';

gn = grd('NANOOS');
Fn = scatteredInterpolant(gn.lat_rho(:), gn.lon_rho(:), 0.*gn.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

stations = {'NH05', 'NH25'};
depths = [-50 -150];
total_depths = [60 296];
lats = [44.652 44.652];
lons = [-124.177 -124.650];

station = stations{si};
depth = depths(si);
total_depth = total_depths(si);
lat_obs = lats(si);
lon_obs = lons(si);

filepath_obs = '/data/jungjih/Observations/NH_line/';
filename_obs = ['temperature_data_', station, '1997_to_2025.csv'];
file_obs = [filepath_obs, filename_obs];
data = readtable(file_obs);
timenum_obs = datenum(table2array(data(:,1)));
timevec_obs = datevec(timenum_obs);
vari_obs_tmp = table2array(data(:,2));

datenum_start = datenum(2023,1,1);
datenum_end = datenum(2024,12,31);
tindex = find(timenum_obs > datenum_start & timenum_obs < datenum_end);
timenum = timenum_obs(tindex);

for di = 1:length(timenum)
    yyyymmdd = datestr(timenum(di), 'yyyymmdd');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));
    dd = str2num(datestr(timenum(di), 'dd'));
    timenum_tmp = timenum(di);

    index = find(timevec_obs(:,1) == yyyy & timevec_obs(:,2) == mm & timevec_obs(:,3) == dd);
    vari_obs(di,:) = vari_obs_tmp(index);

    % NANOOS diff
    vari_NANOOS(di,:) = load_models_profile_daily('NANOOS', gn, vari_str, timenum_tmp, lat_obs, lon_obs, depth);
    
    % WCOFS diff
    vari_WCOFS(di,:) = load_models_profile_daily('WCOFS', gw, vari_str, timenum_tmp, lat_obs, lon_obs, depth);
    
    disp([yyyymmdd, '...'])
end

corrcoef_tmp = corrcoef(vari_obs, vari_NANOOS);
corrcoef_NANOOS = corrcoef_tmp(1,2);
corrcoef_tmp = corrcoef(vari_obs, vari_WCOFS);
corrcoef_WCOFS = corrcoef_tmp(1,2);

vari_NANOOS_diff = vari_NANOOS - vari_obs;
index = find(isnan(vari_NANOOS_diff) == 0);
bias_NANOOS = mean(vari_NANOOS_diff(index));
rmse_NANOOS = sqrt( mean( vari_NANOOS_diff(index).^2 ) );

vari_WCOFS_diff = vari_WCOFS - vari_obs;
index = find(isnan(vari_WCOFS_diff) == 0);
bias_WCOFS = mean(vari_WCOFS_diff(index));
rmse_WCOFS = sqrt( mean( vari_WCOFS_diff(index).^2 ) );

save(['rmse_temp_', station, '.mat'], 'timenum', ...
    'vari_obs', 'vari_NANOOS', 'vari_WCOFS', ...
    'corrcoef_NANOOS', 'corrcoef_WCOFS', ...
    'bias_NANOOS', 'bias_WCOFS', ...
    'rmse_NANOOS', 'rmse_WCOFS');