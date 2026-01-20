%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save results to compare sats SSS to bottom trawl survey salinity
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'SSS';
yyyy_all = [2022:2022];

sat = 'SMOS_BEC';
version = 4;

% Figure properties
vari_roms = 'salt';
interval = 0.25;
climit = [29 34];
num_color = diff(climit)/interval;
contour_interval = climit(1):interval:climit(end);
color = jet(num_color);
unit = 'psu';
vari_obs = 'sea_water_salinity';

% Observation
obs_filepath = '/data/jungjih/Observations/Bottom_trawl_survey/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    obs_filename = ['GAPCTD_', ystr, '_EBS.nc'];
    obs_file = [obs_filepath obs_filename];

    obs_lat_all = ncread(obs_file, 'latitude');
    obs_lon_all = ncread(obs_file, 'longitude');

    if strcmp(vari_str(1:3), 'bot')
        obs_vari = ncread(obs_file, vari_obs);
    else
        obs_vari = ncread(obs_file, vari_obs, [1 1], [1 Inf]);
        obs_vari = obs_vari';
    end

    obs_time = ncread(obs_file, 'time');
    obs_timenum = datenum(obs_time);

    % Observation
    timenum = obs_timenum;

    obs_vari = double(obs_vari);
    obs_lat = double(obs_lat_all);
    obs_lon = double(obs_lon_all);

    if yyyy == 2021
        index = find(timenum > datenum(2021,8,1) & obs_lat < 60);
        timenum(index) = [];
        obs_lat(index) = [];
        obs_lon(index) = [];
        obs_vari(index) = [];
    end

    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
    obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

    [lon_obs2, lat_obs2] = meshgrid(obs_lon_interp, obs_lat_interp);
    vari_obs2 = griddata(obs_lon, obs_lat, obs_vari, lon_obs2, lat_obs2);
    lat_obs = obs_lat;
    lon_obs = obs_lon;

    % Satellite
    vari_sat = [];
    lon_sat = [];
    lat_sat = [];

    for ti = 1:length(timenum_unique)
        timenum_tmp = timenum_unique(ti);
        dindex = find(timenum_floor == timenum_tmp);
        
        [lat, lon, vari] = load_SSS_sat_2d_daily(sat, version, timenum_tmp);
        if strcmp(sat, 'SMOS') & isscalar(vari) == 1
            offset = [1 -1 2 -2 3 -3];
            oi = 0;
            while isscalar(vari) == 1
                oi = oi+1;
                timenum_tmp = timenum_tmp + offset(oi);
                [lat, lon, vari] = load_SSS_sat_2d_daily(sat, version, timenum_tmp);
            end
        end
        if ti == 1
            if strcmp(sat, 'SMOS_BEC')
                F = scatteredInterpolant(lon(:),lat(:),0.*lat(:));
            else
                [lat2, lon2] = meshgrid(lat, lon);
                F = scatteredInterpolant(lon2(:),lat2(:),0.*lat2(:));
            end
        end
        F.Values = vari(:);

        for di = 1:length(dindex)
            lon_tmp = obs_lon(dindex(di));
            lat_tmp = obs_lat(dindex(di));
            if isscalar(vari) == 1
                vari_tmp = NaN;
            else
                vari_tmp = F(lon_tmp, lat_tmp);
            end

            vari_sat = [vari_sat; vari_tmp];
            lon_sat = [lon_sat; lon_tmp];
            lat_sat = [lat_sat; lat_tmp];
        end % di

        disp([num2str(ti), ' / ', num2str(length(timenum_unique)), ' ...'])
    end % ti

    lon_sat2 = lon_obs2;
    lat_sat2 = lat_obs2;
    vari_sat2 = griddata(lon_sat, lat_sat, vari_sat, lon_sat2, lat_sat2);

    save([vari_str, '_', sat, '_trawl_', ystr, '.mat'], 'timenum', 'lon_obs', 'lat_obs', 'lon_obs2', 'lat_obs2', 'vari_obs2', 'lon_sat2', 'lat_sat2', 'vari_sat2');
end % exist