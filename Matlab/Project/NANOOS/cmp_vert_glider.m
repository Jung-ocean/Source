clear; clc; close all

gn = grd('NANOOS');
gw = grd('WCOFS');

yyyy = 2024;
ystr = num2str(yyyy);
mm = 2;

depth_interp = 0:2000;

if yyyy == 2024 & mm == 2
    fi = 5;
    tindex_target = [1:54095];

elseif yyyy == 2024 & mm == 8

end

filepath = '/data/jungjih/Observations/Glider/';
files = dir([filepath, '*', ystr, '*']);

file = [filepath, files(fi).name];

data = readtable(file);

lat = table2array(data(:,8));
lon = table2array(data(:,9));
timenum = datenum(table2array(data(:,2)));
timevec = datevec(timenum);
profile = table2array(data(:,3));
depth = table2array(data(:,4));
temp = table2array(data(:,53));
salt = table2array(data(:,52));
dens = table2array(data(:,18));

tindex = find(timevec(:,2) == mm);
if isempty(tindex) ~= 1
    figure; hold on; grid on;
    plot(lon(tindex),lat(tindex), '.k');
    plot(lon(tindex(tindex_target)),lat(tindex(tindex_target)), 'xr');

    timevec_tmp = timevec(tindex(tindex_target),:);
    lat_tmp = lat(tindex(tindex_target));
    lon_tmp = lon(tindex(tindex_target));
    depth_tmp = depth(tindex(tindex_target));
    profile_tmp = profile(tindex(tindex_target));
    temp_tmp = temp(tindex(tindex_target));
    salt_tmp = salt(tindex(tindex_target));
    dens_tmp = dens(tindex(tindex_target));

    profile_unique = unique(profile_tmp);
    lon_line = []; lat_line = [];
    for pi = 1:length(profile_unique)
        profile_tmp2 = profile_unique(pi);
        pindex = find(profile_tmp == profile_tmp2);
        timevec_tmp2 = timevec_tmp(pindex,:);
        lat_tmp2 = lat_tmp(pindex);
        lon_tmp2 = lon_tmp(pindex);
        depth_tmp2 = depth_tmp(pindex);
        temp_tmp2 = temp_tmp(pindex);
        salt_tmp2 = salt_tmp(pindex);
        dens_tmp2 = dens_tmp(pindex);

        depth_unique = unique(depth_tmp2);
        temp_tmp3 = []; salt_tmp3 = []; dens_tmp3 = [];
        for di = 1:length(depth_unique)
            dindex = find(depth_tmp2 == depth_unique(di));
            temp_tmp3(di) = mean(temp_tmp2(dindex), 'omitnan');
            salt_tmp3(di) = mean(salt_tmp2(dindex), 'omitnan');
            dens_tmp3(di) = mean(dens_tmp2(dindex), 'omitnan');
        end

        datenum_target = unique(floor(datenum(timevec_tmp2)));
        if length(datenum_target) > 1
            datenum_target = datenum_target(1);
        end
        lat_target = unique(lat_tmp2);
        lon_target = unique(lon_tmp2);

        datenum_line(pi) = datenum_target;
        lat_line(pi) = lat_target;
        lon_line(pi) = lon_target;

        % Temperature
        temp_interp(pi,:) = interp1(depth_unique, temp_tmp3, depth_interp);
        temp_NANOOS(pi,:) = load_models_profile_daily('NANOOS', gn, 'temp', datenum_target, lat_target, lon_target, -depth_interp);
        temp_WCOFS(pi,:) = load_models_profile_daily('WCOFS', gw, 'temp', datenum_target, lat_target, lon_target, -depth_interp);

        % Salinity
        salt_interp(pi,:) = interp1(depth_unique, salt_tmp3, depth_interp);
        salt_NANOOS(pi,:) = load_models_profile_daily('NANOOS', gn, 'salt', datenum_target, lat_target, lon_target, -depth_interp);
        salt_WCOFS(pi,:) = load_models_profile_daily('WCOFS', gw, 'salt', datenum_target, lat_target, lon_target, -depth_interp);
        
        % Density
        pden_interp(pi,:) = interp1(depth_unique, dens_tmp3, depth_interp);
        pden_NANOOS(pi,:) = load_models_profile_daily('NANOOS', gn, 'pden', datenum_target, lat_target, lon_target, -depth_interp);
        pden_WCOFS(pi,:) = load_models_profile_daily('WCOFS', gw, 'pden', datenum_target, lat_target, lon_target, -depth_interp);

        disp(['profile ', num2str(pi), '/', num2str(length(profile_unique))])
    end % pi
end

figure; pcolor(temp_interp'); shading flat; caxis([0 14])
figure; pcolor(temp_NANOOS'); shading flat; caxis([0 14])
figure; pcolor(temp_WCOFS'); shading flat; caxis([0 14])

% londist = abs(-125.988 - lon);
% latdist = abs(44.6631 - lat);
% dist = sqrt(londist.^2 + latdist.^2);
% index = find(dist == min(dist))