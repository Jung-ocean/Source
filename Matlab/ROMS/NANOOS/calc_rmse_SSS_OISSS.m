%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate SSS RMSE of NANOOS and WCOFS models
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

vari_str = 'salt';
map = 'US_west';

g = grd('NANOOS');
Fn = scatteredInterpolant(g.lat_rho(:), g.lon_rho(:), 0.*g.lat_rho(:));

gw = grd('WCOFS');
Fw = scatteredInterpolant(gw.lat_rho(:), gw.lon_rho(:), 0.*gw.lat_rho(:));

yyyy_all = 2023:2024;
timenum = datenum(yyyy_all(1),1,1):datenum(yyyy_all(end),12,31);

filepath_obs = '/data/jungjih/Observations/Satellite_SSS/OISSS/daily/';

di = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        di = di+1;
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        % Obs
        filename_obs = ['OISSS_L4_multimission_global_monthly_v2.0_', ystr, '-', mstr, '.nc'];
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

        if yi == 1 & mi == 1
            tmp = vari_NANOOS_diff.*vari_WCOFS_diff;
            index_common = find(isnan(tmp) == 0);
        end

        timenum(di) = datenum(yyyy,mm,1);
        rmse_NANOOS(di) = sqrt( mean( vari_NANOOS_diff(index_common).^2 ) );
        rmse_WCOFS(di) = sqrt( mean( vari_WCOFS_diff(index_common).^2 ) );

        disp([ystr, mstr, '...'])
    end
end
ddd
save(['rmse_SSS_OISSS.mat'], 'index_common', 'timenum', 'rmse_NANOOS', 'rmse_WCOFS')