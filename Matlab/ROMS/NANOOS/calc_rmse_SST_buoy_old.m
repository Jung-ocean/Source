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

yyyy_all = 2023:2024;
mm_all = 1:12;
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    timenum = [timenum datenum(yyyy,mm_all,1)];
end

filepath_obs = '/data/jungjih/Project/NANOOS/';

for di = 1:length(timenum)
    yyyymmdd = datestr(timenum(di), 'yyyymmdd');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));
    dd = str2num(datestr(timenum(di), 'dd'));

    % Obs
    filename_obs = ['SST_buoy_monthly'];
    file_obs = [filepath_obs, filename_obs];
    data = load(file_obs);
    
    lat_obs = data.lats;
    lon_obs = data.lons;
    vari_obs = data.SST_monthly(:,di);
    
    % NANOOS
    vari_NANOOS = load_models_surf_monthly('NANOOS', vari_str, yyyy, mm);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs, lon_obs);
    vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;

    % WCOFS
    vari_WCOFS = load_models_surf_monthly('WCOFS', vari_str, yyyy, mm);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs, lon_obs);
    vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;

    index = find(isnan(vari_NANOOS_diff) == 0);
    num_data(di) = length(index);

    rmse_NANOOS(di) = sqrt( mean( vari_NANOOS_diff(index).^2 ) );
    rmse_WCOFS(di) = sqrt( mean( vari_WCOFS_diff(index).^2 ) );

    disp([yyyymmdd, '...'])
end

save(['rmse_SST_buoy.mat'], 'num_data', 'timenum', 'rmse_NANOOS', 'rmse_WCOFS')