%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save SMOS SSS for a comparison to saildrone
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath_obs = '/data/jungjih/Observations/Saildrone/PMEL_ERDDAP/data/';
filename_obs_all = dir([filepath_obs, '/*.nc']);

for fi = 1:length(filename_obs_all)
    filename_obs = filename_obs_all(fi).name;
    file_obs = [filepath_obs, filename_obs];

    lat = ncread(file_obs, 'latitude');
    lon = ncread(file_obs, 'longitude');
    time = ncread(file_obs, 'time');
    time_units = ncreadatt(file_obs, 'time', 'units');
    id = ncreadatt(file_obs, '/', 'drone_id');
    if strcmp(time_units(1:7), 'seconds')
        timenum_ref = datenum(time_units(15:end), 'yyyy-mm-ddTHH:MM:SSZ');
        timenum_all = time/60/60/24 + timenum_ref;
    else
        pause
    end
    timenum_daily = unique(floor(timenum_all));

    try
        salt = ncread(file_obs, 'SAL_SBE37_MEAN');
        ind_S = 1;
    catch
        ind_S = 0;
    end

    if ind_S == 1

        SSS_SMOS = [];
        err_SMOS = [];
        lat_SMOS = [];
        lon_SMOS = [];
        timenum_SMOS = [];
        for ti = 1:length(timenum_daily)
            timenum = timenum_daily(ti);
            timenum_SMOS(ti) = timenum;

            index = find(timenum_all >= timenum & timenum_all < timenum+1);
            lat_mean = mean(lat(index), 'omitnan');
            lon_mean = mean(lon(index), 'omitnan');

            lat_SMOS(ti) = lat_mean;
            lon_SMOS(ti) = lon_mean;

            % Satellite SSS
            % CEC SMOS v9.0
            filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/4day/'];

            lons_sat = 'lon';
            lons_360ind = [180];
            lats_sat = 'lat';
            varis_sat = 'SSS';
            titles_sat = 'CEC SMOS L3 SSS v9.0';

            filepath_sat = filepath_CEC;
            filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', datestr(timenum, 'yyyymmdd'), '_EASE_09d_25km_v09.nc'];
            file_sat = [filepath_sat, filename_sat];

            numbers = [-1 1 -2 2 -3 3];
            ni = 0;
            if ~exist(file_sat)
                while ~exist(file_sat)
                    ni = ni+1;
                    filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', datestr(timenum+numbers(ni), 'yyyymmdd'), '_EASE_09d_25km_v09.nc'];
                    file_sat = [filepath_sat, filename_sat];
                end
                timenum_SMOS(ti) = timenum_SMOS(ti) + numbers(ni);
                ni = 0;
            end

            lon_sat = double(ncread(file_sat,lons_sat));
            lat_sat = double(ncread(file_sat,lats_sat));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat))');
            err_sat = double(squeeze(ncread(file_sat,'eSSS'))');

            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
            err_sat = [err_sat(:,index1) err_sat(:,index2)];

            lon_sat = lon_sat - lons_360ind;

            [lon_sat2, lat_sat2] = meshgrid(lon_sat, lat_sat);

            vari_sat_interp = interp2(lon_sat2, lat_sat2, vari_sat, lon_mean ,lat_mean);
            err_sat_interp = interp2(lon_sat2, lat_sat2, err_sat, lon_mean ,lat_mean);

            SSS_SMOS(ti) = vari_sat_interp;
            err_SMOS(ti) = err_sat_interp;

            disp([datestr(timenum, 'yyyymmdd...')])
        end % ti

       save(['SSS_SMOS_' filename_obs, '.mat'], 'lat_SMOS', 'lon_SMOS', 'timenum_SMOS', 'SSS_SMOS', 'err_SMOS')
    end
end % fi