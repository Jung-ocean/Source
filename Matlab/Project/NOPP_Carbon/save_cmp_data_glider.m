clear; clc; close all

domain = 'Oregon_1km_large';
expname = 'LiveOcean_nudg';

cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_', expname])

g = grd(domain);

line = 'OR';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 2;
mstr = num2str(mm, '%02i');

depth_interp = 0:2000;

switch line
    case 'OR'
        if yyyy == 2024 & mm == 2
            filename = 'ce_320-20240213T2121_9bd8_0a1f_69a8.nc';
            tindex = [1:54094];
        elseif yyyy == 2024 & mm == 8
            filename = 'ce_1153-20240501T2005_3e99_e1ac_2801.nc';
            tindex = [365064:388486];
        end
    case 'WA'
        if yyyy == 2024 & mm == 3
            filename = 'ce_320-20240213T2121_9bd8_0a1f_69a8.nc';
            tindex = [98756:115180];
        elseif yyyy == 2024 & mm == 8
            filename = 'ce_381-20240806T1850_f860_f72b_b973.nc';
            tindex = [71527:87271];
        end
end

filepath = '/data/jungjih/Observations/Glider/netcdf/';
file = [filepath, filename];

lon = ncread(file, 'longitude');
lat = ncread(file, 'latitude');
time_tmp = ncread(file, 'time');
timenum = time_tmp/60/60/24 + datenum(1970,1,1);
timevec = datevec(timenum);
profile = ncread(file, 'profile_id');
depth = ncread(file, 'depth');
temp = ncread(file, 'temperature');
salt = ncread(file, 'salinity');
dens = ncread(file, 'density');

if isempty(tindex) ~= 1
    figure; hold on; grid on;
    plot(lon(tindex),lat(tindex), 'rx');

    timevec_tmp = timevec(tindex,:);
    lat_tmp = lat(tindex);
    lon_tmp = lon(tindex);
    depth_tmp = depth(tindex);
    profile_tmp = profile(tindex);
    temp_tmp = temp(tindex);
    salt_tmp = salt(tindex);
    dens_tmp = dens(tindex);

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
        depth_unique(isnan(depth_unique) == 1) = [];
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

        profile = load_models_profile_daily(domain, expname, g, datenum_target, lon_target, lat_target);

        % Temperature
        temp_interp(pi,:) = interp1(depth_unique, temp_tmp3, depth_interp);
        temp_ROMS(pi,:) = interp1(profile.depth, profile.temp, -depth_interp);
        
        % Salinity
        salt_interp(pi,:) = interp1(depth_unique, salt_tmp3, depth_interp);
        salt_ROMS(pi,:) = interp1(profile.depth, profile.salt, -depth_interp);
        
        % Potential density
        addpath(genpath('/home/server/pi/homes/jungjih/Source/Matlab/Tools/gsw'));
        p = gsw_p_from_z(-depth_interp,lat_target);
        [SA, in_ocean] = gsw_SA_from_SP(salt_interp(pi,:),p,lon_target,lat_target);
        CT = gsw_CT_from_t(SA,temp_interp(pi,:),p);
        pden = gsw_rho(SA,CT,0);
        rmpath(genpath('/home/server/pi/homes/jungjih/Source/Matlab/Tools/gsw'));

        pden_interp(pi,:) = pden;
        pden_ROMS(pi,:) = interp1(profile.depth, profile.pden, -depth_interp);

        disp(['profile ', num2str(pi), '/', num2str(length(profile_unique))])
    end % pi
end

save(['cmp_data_glider_', domain, '_', expname, '_', line, '_', ystr, mstr, '.mat'], ...
    'datenum_line', 'lat_line', 'lon_line', 'depth_interp', ...
    'temp_interp', 'temp_ROMS', ...
    'salt_interp', 'salt_ROMS', ...
    'pden_interp', 'pden_ROMS');