%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save vertical ts 1 hourly from Bering Sea mooring data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/data/';
filenames_obs = dir([filepath_obs, '/1hr*']);

for fi = 1:length(filenames_obs)
    filename_obs = filenames_obs(fi).name;
    file_obs = [filepath_obs, filename_obs];

    lon_obs = ncread(file_obs, 'longitude');
    lon_obs(lon_obs > 180) = lon_obs(lon_obs > 180)-360;
    if fi == 2
        lat_obs = 57.8677*(lon_obs./lon_obs);
    else
        lat_obs = ncread(file_obs, 'latitude');
    end
    time_obs = ncread(file_obs, 'time');
    timenum_obs = time_obs/60/60/24 + datenum(1970,1,1);
    depth_obs = ncread(file_obs, 'depth');
    temp_obs = ncread(file_obs, 'temperature')';
    salt_obs = ncread(file_obs, 'salinity')';

    depth_1m = 0:max(depth_obs);
    timenum_1h = timenum_obs(1):1/24:timenum_obs(end);
    temp_obs_1h = NaN(length(depth_1m), length(timenum_1h));
    salt_obs_1h = NaN(length(depth_1m), length(timenum_1h));
    for ti = 1:length(timenum_1h)
        tindex = find(timenum_obs > timenum_1h(ti)-1e-4 & timenum_obs < timenum_1h(ti)+1/24);
        if isempty(tindex)
            temp_obs_1h(:,ti) = NaN;
            salt_obs_1h(:,ti) = NaN;
        else
            for di = 1:length(depth_1m)
                dindex = find(depth_obs == depth_1m(di));
                if isempty(dindex)
                    temp_obs_1h(di,ti) = NaN;
                    salt_obs_1h(di,ti) = NaN;
                else
                    temp_obs_1h(di,ti) = mean(temp_obs(dindex,tindex),2);
                    salt_obs_1h(di,ti) = mean(salt_obs(dindex,tindex),2);
                end
            end
        end
    end
   
    if fi == 3 % M5 mooring abnormal salinity
        index = find(depth_1m == 52);
        salt_obs_1h(index,:) = NaN;
    end

    figure; pcolor(timenum_obs, -depth_obs, temp_obs); shading flat; caxis([-2 12])
    figure; pcolor(timenum_1h, -depth_1m, temp_obs_1h); shading flat; caxis([-2 12])
    figure; pcolor(timenum_obs, -depth_obs, salt_obs); shading flat; caxis([29.5 33.5])
    figure; pcolor(timenum_1h, -depth_1m, salt_obs_1h); shading flat; caxis([29.5 33.5])

    save(['ts_1h_', filename_obs(18:20), '.mat'], 'lon_obs', 'lat_obs', 'timenum_1h', 'depth_1m', 'temp_obs_1h', 'salt_obs_1h')
end