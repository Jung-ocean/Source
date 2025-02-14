%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save freeboard from ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 1:6;

g = grd('BSf');

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/Freeboard/data/';

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

    filename = dir([filepath, 'ATL20-01_', ystr, mstr, '*']);
    filename = filename.name;
    file = [filepath, filename];

    lat = h5read(file, '/grid_lat')';
    lon = h5read(file, '/grid_lon')';
    grid_x = h5read(file, '/grid_x')';
    grid_y = h5read(file, '/grid_y')';

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        try
            freeboard = h5read(file, ['/daily/day', dstr, '/mean_fb'])';
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_fb/'], '_FillValue');
            freeboard(freeboard == fv) = NaN;
        catch
            freeboard = NaN;
        end

        index = find(isnan(freeboard) ~= 1);
        lon_data = lon(index);
        lat_data = lat(index);
        freeboard_data = freeboard(index);

        index1 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data > min(g.lon_rho(:))+360);
        index2 = find(lat_data > min(g.lat_rho(:)) & lat_data < max(g.lat_rho(:)) ...
            & lon_data < max(g.lon_rho(:)));
        index = [index1; index2];

        lat_Bering = lat_data(index);
        lon_Bering = lon_data(index);
        lon_Bering(lon_Bering > 0) = lon_Bering(lon_Bering > 0) - 360;
        freeboard_Bering = freeboard_data(index);

        % Cut out data outside the ROMS domain
        [in, on] = inpolygon(lon_Bering, lat_Bering, polygon(:,1), polygon(:,2));
        lat_target = lat_Bering(~in);
        lon_target = lon_Bering(~in);
        freeboard_target = freeboard_Bering(~in);

        data_ICESat2(dataind).timenum = datenum(yyyy,mm,dd);
        data_ICESat2(dataind).lat_freeboard = lat_target;
        data_ICESat2(dataind).lon_freeboard = lon_target;
        data_ICESat2(dataind).freeboard = freeboard_target;

        dataind = dataind + 1;
    end
end

save(['freeboard_ICESat2_', ystr, '.mat'], 'data_ICESat2')