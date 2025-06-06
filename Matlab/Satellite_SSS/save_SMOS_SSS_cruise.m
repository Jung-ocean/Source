%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save SMOS SSS for a comparison to saildrone
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

    SSS_SMOS = [];
    err_SMOS = [];
    lat_SMOS = [];
    lon_SMOS = [];
    timenum_SMOS = [];
    for ti = 1:length(timenum_all)
        timenum = floor(timenum_all(ti));
        ystr = datestr(timenum, 'yyyy');
        mstr = datestr(timenum, 'mm');
        timenum_SMOS(ti) = timenum;

        lat_mean = lat(ti);
        lon_mean = lon(ti);

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

        if ismonthly == 1
            filepath_sat = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];
            filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_09d_25km_v09.nc'];
            timenum_SMOS(ti) = datenum(str2num(ystr), str2num(mstr), 15);
        else
            filepath_sat = filepath_CEC;
            filename_sat = ['SMOS_L3_DEBIAS_LOCEAN_AD_', datestr(timenum, 'yyyymmdd'), '_EASE_09d_25km_v09.nc'];
        end
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

        if ismonthly == 1
            save(['SSS_SMOS_' filename_obs, '_monthly.mat'], 'lat_SMOS', 'lon_SMOS', 'timenum_SMOS', 'SSS_SMOS', 'err_SMOS')
        else
            save(['SSS_SMOS_' filename_obs, '.mat'], 'lat_SMOS', 'lon_SMOS', 'timenum_SMOS', 'SSS_SMOS', 'err_SMOS')
        end
end % fi