%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate SSH RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'zeta';
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

for di = 1:length(timenum)
    ystr = datestr(timenum(di), 'yyyy');
    mstr = datestr(timenum(di), 'mm');
    yyyy = str2num(ystr);
    mm = str2num(mstr);

    % Obs
    filepath_obs = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/'];
    filename_obs = ['dt_global_allsat_phy_l4_monthly_', ystr, mstr, '.nc'];
    file_obs = [filepath_obs, filename_obs];
    try
        lat_obs = double(ncread(file_obs, 'latitude'));
        lon_obs = double(ncread(file_obs, 'longitude'));
        vari_obs_tmp = 100*ncread(file_obs, 'adt');
        index1 = find(lon_obs<0);
        index2 = find(lon_obs>0);
        lon_obs = [lon_obs(index2)-360; lon_obs(index1)];
        vari_obs_tmp = [vari_obs_tmp(index2,:); vari_obs_tmp(index1,:)];

        [lon_limit, lat_limit] = load_domain(map);
        lonind = find(lon_obs > min(lon_limit) & lon_obs < max(lon_limit));
        latind = find(lat_obs > min(lat_limit) & lat_obs < max(lat_limit));

        [lat_obs2, lon_obs2] = meshgrid(lat_obs(latind), lon_obs(lonind));
        vari_obs = vari_obs_tmp(lonind, latind);
        vari_obs = vari_obs - mean(vari_obs(:), 'omitnan');
    catch
        rmse_NANOOS(di) = NaN;
        rmse_WCOFS(di) = NaN;
        continue
    end

    % NANOOS
    vari_NANOOS = 100.*load_models_surf_monthly('NANOOS', vari_str, yyyy, mm);
    Fn.Values = vari_NANOOS(:);
    vari_NANOOS_interp = Fn(lat_obs2, lon_obs2);
    vari_NANOOS_interp = vari_NANOOS_interp - mean(vari_NANOOS_interp(:), 'omitnan');
    vari_NANOOS_diff = vari_NANOOS_interp - vari_obs;

    % WCOFS
    vari_WCOFS = 100.*load_models_surf_monthly('WCOFS', vari_str, yyyy, mm);
    Fw.Values = vari_WCOFS(:);
    vari_WCOFS_interp = Fw(lat_obs2, lon_obs2);
    vari_WCOFS_interp = vari_WCOFS_interp - mean(vari_WCOFS_interp(:), 'omitnan');
    vari_WCOFS_diff = vari_WCOFS_interp - vari_obs;

    if di == 1
        tmp = vari_NANOOS_diff.*vari_WCOFS_diff;
        index_common = find(isnan(tmp) == 0);
    end

    rmse_NANOOS(di) = sqrt( mean( vari_NANOOS_diff(index_common).^2 ) );
    rmse_WCOFS(di) = sqrt( mean( vari_WCOFS_diff(index_common).^2 ) );

    disp([ystr, mstr, '...'])
end

save(['rmse_SSH_CMEMS.mat'], 'index_common', 'timenum', 'rmse_NANOOS', 'rmse_WCOFS')