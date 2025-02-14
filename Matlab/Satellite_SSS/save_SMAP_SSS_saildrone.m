%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save SMAP SSS for a comparison to saildrone
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

        SSS_SMAP = [];
        err_SMAP = [];
        timenum_SMAP = [];
        lat_SMAP = [];
        lon_SMAP = [];
        for ti = 1:length(timenum_daily)
            timenum = timenum_daily(ti);
            ystr = datestr(timenum, 'yyyy');
            timenum_SMAP(ti) = timenum;
            filenum_SMAP = timenum - datenum(str2num(datestr(timenum, 'yyyy')), 1, 1) + 1;
            fstr_SMAP = num2str(filenum_SMAP, '%03i');

            index = find(timenum_all >= timenum & timenum_all < timenum+1);
            lat_mean = mean(lat(index), 'omitnan');
            lon_mean = mean(lon(index), 'omitnan');

            lat_SMAP(ti) = lat_mean;
            lon_SMAP(ti) = lon_mean;

            % Satellite SSS
            % RSS SMAP v6.0
            filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/8day_running/', ystr, '/'];

            lons_sat = 'lon';
            lons_360ind = [360];
            lats_sat = 'lat';
            varis_sat = 'sss_smap';
            titles_sat = 'RSS SMAP L3 SSS v6.0 (70 km)';

            filepath_sat = filepath_RSS_70;
            filename_sat = ['RSS_smap_SSS_L3_8day_running_', ystr, '_', fstr_SMAP, '_FNL_v06.0.nc'];
            file_sat = [filepath_sat, filename_sat];

            if ~exist(file_sat)
                SSS_SMAP(ti) = NaN;
                err_SMAP(ti) = NaN;
                continue
            end

            lon_sat = double(ncread(file_sat,lons_sat));
            lat_sat = double(ncread(file_sat,lats_sat));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat))');
            err_sat = double(squeeze(ncread(file_sat,'sss_smap_unc'))');

            lon_sat = lon_sat - lons_360ind;

            [lon_sat2, lat_sat2] = meshgrid(lon_sat, lat_sat);

            vari_sat_interp = interp2(lon_sat2, lat_sat2, vari_sat, lon_mean ,lat_mean);
            err_sat_interp = interp2(lon_sat2, lat_sat2, err_sat, lon_mean ,lat_mean);

            SSS_SMAP(ti) = vari_sat_interp;
            err_SMAP(ti) = err_sat_interp;

            disp([datestr(timenum, 'yyyymmdd...')])
        end % ti

       save(['SSS_SMAP_' filename_obs, '.mat'], 'lat_SMAP', 'lon_SMAP', 'timenum_SMAP', 'SSS_SMAP', 'err_SMAP')
    end
end % fi