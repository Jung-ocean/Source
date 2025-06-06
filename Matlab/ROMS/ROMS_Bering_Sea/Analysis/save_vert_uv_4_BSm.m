%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save vertical uv from ROMS output for the purpose of comparison to BSm
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

g = grd('BSf');

yyyy = 2023;
ystr = num2str(yyyy);
mm_start = 1;
mm_end = 12;

stations = {'M2', 'M4', 'M5', 'M8'};
names = {'bs2', 'bs4', 'bs5', 'bs8'};
lats = [56.8712 57.8677 59.9066 62.1943];
lons = [-164.0564 -168.8859 -171.7112 -174.6786];

filepath_obs = '/data/jungjih/Observations/Bering_Sea_mooring/figures/';

for si = 1:length(stations)
    filename_obs = ['uv_1h_', names{si}, '.mat'];
    file_obs = [filepath_obs, filename_obs];
    load(file_obs)
    lat_target = mean(lat_obs(:), 'omitnan');
    lon_target = mean(lon_obs(:), 'omitnan');

    tindex1 = find(timenum_1h > datenum(yyyy,mm_start,1) & timenum_1h < datenum(yyyy,7,2));
    tindex2 = find(timenum_1h >= datenum(yyyy,7,2) & timenum_1h < datenum(yyyy,mm_end+1,1));
    timenum1 = timenum_1h(tindex1);
    timenum2 = timenum_1h(tindex2);

    timenum = [timenum1 timenum2];
    u_model = [];
    v_model = [];
    for ti = 1:2
        timenum_tmp = eval(['timenum', num2str(ti)]);
        if yyyy == 2021 & ti == 1
            filepath = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2020/Dsm4_nKC/';
            filename = 'Winter_2020_Dsm4_nKC_sta.nc';
        elseif yyyy == 2021 & ti == 2
            filepath = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2021/Dsm4_nKC/';
            filename = 'SumFal_2021_Dsm4_nKC_sta.nc';
        elseif yyyy == 2023 & ti == 1
            filepath = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/';
            filename = 'Winter_2022_Dsm4_nKC_sta.nc';
        elseif yyyy == 2023 & ti == 2
            filepath = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2023/Dsm4_nKC/Output/';
            filename = 'SumFal_2023_Dsm4_nKCr_sta.nc';
        end
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        timenum_model = ot/60/60/24 + datenum(1968,5,23);
        lat_all = ncread(file, 'lat_rho');
        lon_all = ncread(file, 'lon_rho');
        dist = sqrt( (lat_all-lat_target).^2 + (lon_all-lon_target).^2 );
        staind = find(dist == min(dist));
        
        lat_model = lat_all(staind);
        lon_model = lon_all(staind);
        h = ncread(file, 'h', [staind], [1]);
        zeta = ncread(file, 'zeta', [staind, 1], [1, Inf]);
        u = squeeze(ncread(file, 'u', [1 staind, 1], [Inf, 1, Inf]));
        v = squeeze(ncread(file, 'v', [1 staind, 1], [Inf, 1, Inf]));
        
        zeta_tinterp = NaN(length(timenum_tmp),1);
        u_tinterp = NaN(size(u,1), length(timenum_tmp));
        v_tinterp = NaN(size(v,1), length(timenum_tmp));
        for tti = 1:length(timenum_tmp)
            index = find(timenum_model > timenum_tmp(tti)-1e-4 & timenum_model < timenum_tmp(tti)+1/24);

            zeta_tinterp(tti) = mean(zeta(index));
            u_tinterp(:,tti) = mean(u(:,index),2);
            v_tinterp(:,tti) = mean(v(:,index),2);
        end
        depth = -squeeze(zlevs(h,zeta_tinterp,g.theta_s,g.theta_b,g.hc,g.N,'r',2))';

        u_dinterp = NaN(length(depth_1m), size(u_tinterp,2));
        v_dinterp = NaN(length(depth_1m), size(u_tinterp,2));
        for di = 1:size(u_tinterp,2)        
            u_dinterp(:,di) = interp1(depth(:,di), u_tinterp(:,di), depth_1m);
            v_dinterp(:,di) = interp1(depth(:,di), v_tinterp(:,di), depth_1m);
        end

        u_model = [u_model u_dinterp*100];
        v_model = [v_model v_dinterp*100];
    end

    save(['uv_1h_', names{si}, '_ROMS_', ystr, '.mat'], 'depth_1m', 'lat_model', 'lon_model', 'timenum', 'u_model', 'v_model')
end