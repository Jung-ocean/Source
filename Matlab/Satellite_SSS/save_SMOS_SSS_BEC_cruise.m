%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save SMOS SSS for a comparison to saildrone
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

ismonthly = 0;

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

for fi = 1:1%length(files)
    file_obs = files{fi};
    data = load(file_obs);
    filename_obs = filenames_obs{fi};

    lat = data.lat;
    lon = data.lon;
    timenum_all = data.timenum;

    SSS_SMOS_BEC = [];
    err_SMOS_BEC = [];
    lat_SMOS_BEC = [];
    lon_SMOS_BEC = [];
    timenum_SMOS_BEC = [];
    for ti = 1:length(timenum_all)
        timenum = floor(timenum_all(ti));
        ystr = datestr(timenum, 'yyyy');
        mstr = datestr(timenum, 'mm');
        timenum_SMOS_BEC(ti) = timenum;

        lat_mean = lat(ti);
        lon_mean = lon(ti);

        lat_SMOS_BEC(ti) = lat_mean;
        lon_SMOS_BEC(ti) = lon_mean;

        % Satellite SSS
        sat = 'SMOS_BEC';
        version = 4;

        if ismonthly == 1
            
        else
            [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_daily(sat, version, timenum);
        end
        if ti == 1
            F = scatteredInterpolant(lon_sat(:), lat_sat(:), 0.*lat_sat(:));
        end
        F.Values = vari_sat(:);

%         err_sat = double(squeeze(ncread(file_sat,'eSSS'))');
%         err_sat = [err_sat(:,index1) err_sat(:,index2)];

        vari_sat_interp = F(lon_mean ,lat_mean);
%         err_sat_interp = interp2(lon_sat2, lat_sat2, err_sat, lon_mean ,lat_mean);

        SSS_SMOS_BEC(ti) = vari_sat_interp;
%         err_SMOS(ti) = err_sat_interp;

        disp([datestr(timenum, 'yyyymmdd...')])
    end % ti

        if ismonthly == 1
            save(['SSS_SMOS_BEC_' filename_obs, '_monthly.mat'], 'lat_SMOS_BEC', 'lon_SMOS_BEC', 'timenum_SMOS_BEC', 'SSS_SMOS_BEC')
        else
            save(['SSS_SMOS_BEC_' filename_obs, '.mat'], 'lat_SMOS_BEC', 'lon_SMOS_BEC', 'timenum_SMOS_BEC', 'SSS_SMOS_BEC')
        end
end % fi