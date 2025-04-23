%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output SST to OSTIA monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
vari_str = 'SST';
yyyy_all = 2019:2022;
mm = 7;

region = 'Gulf_of_Anadyr';

iswind = 0;
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 5;
scale_wind = 0.8;

switch vari_str
    case 'SST'
        climit = [4 12];
        interval = .5;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = '^oC';
end

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/monthly/'];

% OSTIA
obs_filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/monthly/'];

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

h1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(2,4);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    mstr = num2str(mm, '%02i');
    timenum = datenum(yyyy,mm,15);

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath_control, filename];
    if ~exist(file)
        vari = NaN;
    else
        vari = mask.*ncread(file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';
    end

    % Figure title
    title(t, ['SST in ', datestr(timenum, 'mmm')], 'FontSize', 25);

    nexttile(yi)
    plot_map(region, 'mercator', 'l')
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(2)) = climit(2);
    [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    %     plot_map(map, 'mercator', 'l')

    if yi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        %         c.Ticks = climit_model(1):4:climit_model(end);
        c.FontSize = 15;
    end
    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, datestr(timenum, 'mmm, yyyy'), 'FontSize', text_FS)

    if iswind == 1

        ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
        ERA5_file = [ERA5_filepath, ERA5_filename];

        ERA5_lon = ncread(ERA5_file, 'longitude');
        ERA5_lat = ncread(ERA5_file, 'latitude');
        ERA5_uwind = ncread(ERA5_file, 'u10')';
        ERA5_vwind = ncread(ERA5_file, 'v10')';

        [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon), double(ERA5_lat));

        q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            0);
        q(1).Color = 'k';
        q(2).Color = 'k';

        qscale = quiverm(64, -184.5, 0.*scale_wind, 3.*scale_wind, 0);
        qscale(1).Color = 'r';
        qscale(2).Color = 'r';
        tscale = textm(63.5, -184.5, '3 m/s', 'Color', 'r', 'FontSize', 12);
    end

    % Satellite
    obs_filename = ['OSTIA_', ystr, mstr, '.nc'];
    obs_file = [obs_filepath, obs_filename];

    lon_sat = double(ncread(obs_file, 'lon'));
    lat_sat = double(ncread(obs_file, 'lat'));
    vari_sat = ncread(obs_file, 'analysed_sst')' - 273.15; % K to dec C

    index1 = find(lon_sat < 0);
    index2 = find(lon_sat > 0);

    lon_sat = [lon_sat(index2)-360; lon_sat(index1)];
    vari_sat = [vari_sat(:,index2) vari_sat(:,index1)];

    % Tile
    nexttile(4+yi);

    plot_map(region, 'mercator', 'l')
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

    latind = find(40<lat_sat & lat_sat <80);
    lonind = find(-250<lon_sat & lon_sat <-100);
    lat_sat = lat_sat(latind);
    lon_sat = lon_sat(lonind);
    vari_sat = vari_sat(latind,lonind);
    [lon2, lat2] = meshgrid(lon_sat, lat_sat);
    [x, y] = mfwdtran(lat2, lon2);  % Convert lat/lon to projected x, y coordinates
    vari_sat(vari_sat < climit(1)) = climit(1);
    vari_sat(vari_sat > climit(2)) = climit(2);
    [cs, T] = contourf(x, y, vari_sat, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    %     plot_map(region, 'mercator', 'l')

    textm(text1_lat, text1_lon, 'OSTIA', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, datestr(timenum, 'mmm, yyyy'), 'FontSize', text_FS)
end % yi

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['cmp_map_', vari_str, '_OSTIA_monthly_', mstr],'-dpng');