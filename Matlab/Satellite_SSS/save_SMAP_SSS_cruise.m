%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save SMAP SSS for a comparison to cruise data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

ismonthly = 1;

files = {
    '/data/jungjih/Observations/Nomura_etal_2021/data_Nomura_etal_2021_2018.mat'
    '/data/jungjih/Observations/NIPR_ARD/A20191216-015/data_NIPR_ARD_2017.mat'
    '/data/jungjih/Observations/NIPR_ARD/A20240705-007/data_NIPR_ARD_2023.mat'
    };
filenames_obs = {
    'Nomura_etal_2021_2018'
    'NIPR_ARD_2017'
    'NIPR_ARD_2023'
};

for fi = 1:length(files)
    file_obs = files{fi};
    data = load(file_obs);
    filename_obs = filenames_obs{fi};

    lat = data.lat;
    lon = data.lon;
    timenum_all = data.timenum;

    SSS_SMAP = [];
    err_SMAP = [];
    timenum_SMAP = [];
    lat_SMAP = [];
    lon_SMAP = [];
    for ti = 1:length(timenum_all)
        timenum = floor(timenum_all(ti));
        ystr = datestr(timenum, 'yyyy');
        mstr = datestr(timenum, 'mm');
        timenum_SMAP(ti) = timenum;
        filenum_SMAP = timenum - datenum(str2num(datestr(timenum, 'yyyy')), 1, 1) + 1;
        fstr_SMAP = num2str(filenum_SMAP, '%03i');

        lat_mean = lat(ti);
        lon_mean = lon(ti);

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

        if ismonthly == 1
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/monthly/', ystr, '/'];
            filename_sat = ['RSS_smap_SSS_L3_monthly_', ystr, '_', mstr, '_FNL_v06.0.nc'];
            timenum_SMAP(ti) = datenum(str2num(ystr), str2num(mstr), 15);
        else
            filepath_sat = filepath_RSS_70;
            filename_sat = ['RSS_smap_SSS_L3_8day_running_', ystr, '_', fstr_SMAP, '_FNL_v06.0.nc'];
        end
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

    if ismonthly == 1
        save(['SSS_SMAP_' filename_obs, '_monthly.mat'], 'lat_SMAP', 'lon_SMAP', 'timenum_SMAP', 'SSS_SMAP', 'err_SMAP')
    else
        save(['SSS_SMAP_' filename_obs, '.mat'], 'lat_SMAP', 'lon_SMAP', 'timenum_SMAP', 'SSS_SMAP', 'err_SMAP')
    end
end % fi