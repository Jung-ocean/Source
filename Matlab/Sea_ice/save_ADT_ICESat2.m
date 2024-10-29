%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save ADT from ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 1:6;

g = grd('BSf');

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/data/';

ystr = num2str(yyyy);

polygon = [
    -205.8165   63.9824
    -188.8137   63.9824
    -198.7042   58.9821
    -203.5939   51.2265
    -205.7053   49.8488
    ];

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
dataind = 1;
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename = dir([filepath, 'ATL21-01_', ystr, mstr, '*']);
    filename = filename.name;
    file = [filepath, filename];

    lat = h5read(file, '/grid_lat')';
    lon = h5read(file, '/grid_lon')';
    grid_x = h5read(file, '/grid_x')';
    grid_y = h5read(file, '/grid_y')';

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        try
            ssha = h5read(file, ['/daily/day', dstr, '/mean_ssha'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
            ssha(ssha == fv) = NaN;
            mss = h5read(file, ['/daily/day', dstr, '/mean_weighted_mss'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
            mss(mss == fv) = NaN;
            geoid = h5read(file, ['/daily/day', dstr, '/mean_weighted_geoid'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
            geoid(geoid == fv) = NaN;
        catch
            ssha = NaN;
            mss = NaN;
            geoid = NaN;
        end

        ADT = mss + ssha - geoid;

        index = find(isnan(ADT) ~= 1);
        lon_data = lon(index);
        lat_data = lat(index);
        ADT_data = ADT(index);

        index1 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data > min(g.lon_rho(:))+360);
        index2 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data < max(g.lon_rho(:)));
        index = [index1; index2];

        lat_Bering = lat_data(index);
        lon_Bering = lon_data(index);
        lon_Bering(lon_Bering > 0) = lon_Bering(lon_Bering > 0) - 360;
        ADT_Bering = ADT_data(index);

        % Cut out data outside the ROMS domain
        [in, on] = inpolygon(lon_Bering, lat_Bering, polygon(:,1), polygon(:,2));
        lat_target = lat_Bering(~in);
        lon_target = lon_Bering(~in);
        ADT_target = ADT_Bering(~in);

        data_ICESat2(dataind).timenum = datenum(yyyy,mm,dd);
        data_ICESat2(dataind).lat_ADT = lat_target;
        data_ICESat2(dataind).lon_ADT = lon_target;
        data_ICESat2(dataind).ADT = ADT_target;

        dataind = dataind + 1;
    end
end

save(['ADT_ICESat2_', ystr, '.mat'], 'data_ICESat2')