%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate uv RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'temp';
map = 'US_west';

g = grd('NANOOS');
Fn = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), 0.*g.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

yyyy_all = 2023:2024;
mm_all = 1:12;
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    timenum = [timenum datenum(yyyy,mm_all,1)];
end

filepath_obs = '/data/jungjih/Observations/Satellite_SST/OISST/monthly/';

for di = 1:length(timenum)
    yyyymm = datestr(timenum(di), 'yyyymm');
    yyyy = str2num(datestr(timenum(di), 'yyyy'));
    mm = str2num(datestr(timenum(di), 'mm'));

    % Obs
    filename_obs = ['OISST_', yyyymm, '.nc'];
    file_obs = [filepath_obs, filename_obs];
    lat_obs = double(ncread(file_obs, 'lat'));
    lon_obs = double(ncread(file_obs, 'lon'));
    lon_obs = lon_obs-360;

    [lon_limit, lat_limit] = load_domain(map);
    lonind = find(lon_obs > min(lon_limit) & lon_obs < max(lon_limit));
    latind = find(lat_obs > min(lat_limit) & lat_obs < max(lat_limit));

    [lat_obs2, lon_obs2] = meshgrid(lat_obs(latind), lon_obs(lonind));
    vari_obs_tmp = ncread(file_obs, 'sst');
    vari_obs = vari_obs_tmp(lonind, latind);

    % NANOOS
    vari_NANOOS = load_models_surf_monthly('NANOOS', vari_str, yyyy, mm);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs2, lon_obs2);
    vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;

    % WCOFS
    vari_WCOFS = load_models_surf_monthly('WCOFS', vari_str, yyyy, mm);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs2, lon_obs2);
    vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;

    if di == 1
        tmp = vari_NANOOS_diff.*vari_WCOFS_diff;
        index_common = find(isnan(tmp) == 0);
    end

    SST_OISST(di) = mean(vari_obs(index_common), 'omitnan');
    SST_NANOOS(di) = mean(vari_NANOOS_interp(index_common), 'omitnan');
    SST_WCOFS(di) = mean(vari_WCOFS_interp(index_common), 'omitnan');

    rmse_NANOOS(di) = sqrt( mean( vari_NANOOS_diff(index_common).^2 ) );
    rmse_WCOFS(di) = sqrt( mean( vari_WCOFS_diff(index_common).^2 ) );

    disp([yyyymm, '...'])
end

save(['rmse_SST_OISST.mat'], 'index_common', 'timenum', 'rmse_NANOOS', 'rmse_WCOFS', 'SST_OISST', 'SST_NANOOS', 'SST_WCOFS')