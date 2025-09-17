clear; clc; close all

exp = 'Dsm4';
map = 'Bering';
startdate = datenum(2018,7,1);
reftime = datenum(1968,5,23);

timenum_start = datenum(2022,4,1);
tsstr = datestr(timenum_start, 'yyyymmdd');
timenum_end = datenum(2022,7,31);
testr = datestr(timenum_end, 'yyyymmdd');

g = grd('BSf');

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/ERA5/';

switch map
    case 'NW_Bering'
        text_uvbar_lat = 65.8;
        text_uvbar_lon = -192.5;

        text_wind_lat = 63.4;
        text_wind_lon = text_uvbar_lon;

        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;

        color_uvbar = [1.0000 0.0745 0.6510];
        interval_uvbar = 20;
        scale_uvbar = 3;
        scale_uvbar_value = 0.4;
        scale_uvbar_lat = text_uvbar_lat-0.7;
        scale_uvbar_lon = text_uvbar_lon;
        scale_uvbar_text = '40 cm/s';
        scale_uvbar_text_lat = scale_uvbar_lat-0.6;
        scale_uvbar_text_lon = text_uvbar_lon;

        color_wind = [0.0588 1.0000 1.0000];
        interval_wind = 6;
        scale_wind = 0.1;
        scale_wind_value = 10;
        scale_wind_lat = text_wind_lat-0.7;
        scale_wind_lon = text_wind_lon;
        scale_wind_text = '10 m/s';
        scale_wind_text_lat = scale_wind_lat-0.6;
        scale_wind_text_lon = text_wind_lon;

    case 'Bering'
        text_uvbar_lat = 65.8;
        text_uvbar_lon = -192.5;

        text_wind_lat = 63.4;
        text_wind_lon = text_uvbar_lon;

        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;

        color_uvbar = 'k';
        interval_uvbar = 40;
        scale_uvbar = 12;
        scale_uvbar_value = 0.1;
        scale_uvbar_lat = text_uvbar_lat-0.7;
        scale_uvbar_lon = text_uvbar_lon;
        scale_uvbar_text = '10 cm/s';
        scale_uvbar_text_lat = scale_uvbar_lat-0.6;
        scale_uvbar_text_lon = text_uvbar_lon;

        color_wind = [1.0000 0.0745 0.6510];
        interval_wind = 6;
        scale_wind = 0.1;
        scale_wind_value = 10;
        scale_wind_lat = text_wind_lat-0.7;
        scale_wind_lon = text_wind_lon;
        scale_wind_text = '10 m/s';
        scale_wind_text_lat = scale_wind_lat-0.6;
        scale_wind_text_lon = text_wind_lon;
end

% Adjust vector
[scale_uvbar_value, scale_ice_v, lon_scl] = adjust_vector(scale_uvbar_lon, scale_uvbar_lat, scale_uvbar_value, 0);

% Adjust vector
[scale_wind_value, scale_wind_v, lon_scl] = adjust_vector(scale_wind_lon, scale_wind_lat, scale_wind_value, 0);

% Figure properties
interval = 2.5;
climit = [-40 40];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'cm';

h1 = figure;
set(gcf, 'Position', [1 200 800 500])
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

t1 = textm(text_uvbar_lat, text_uvbar_lon, 'uvbar', 'Color', color_uvbar, 'FontSize', text_FS);
t2 = textm(text_wind_lat, text_wind_lon, 'Wind', 'Color', color_wind, 'FontSize', text_FS);

for ti = timenum_start:timenum_end
    timenum_tmp = ti;
    timevec = datevec(timenum_tmp);
    yyyy = timevec(:,1);
    ystr = num2str(yyyy);
    mm = timevec(:,2);
    mstr = num2str(mm, '%02i');

    filenum = timenum_tmp - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];
    zeta = 100*ncread(file, 'zeta'); % m to cm
    ubar = ncread(file, 'ubar');
    vbar = ncread(file, 'vbar');
    ot = ncread(file, 'ocean_time');

    timenum = ot/60/60/24 + reftime;
    time_title = datestr(timenum-.5, 'mmm dd, yyyy');

    title([time_title], 'FontSize', 15)

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari = zeta;
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);

    %     [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    T=pcolorm(g.lat_rho,g.lon_rho,vari);
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')

    c = colorbar;
    c.Title.String = unit;
    c.FontSize = 12;

    qscale_uvbar = quiverm_J(scale_uvbar_lat, scale_uvbar_lon, 0.*scale_uvbar, scale_uvbar_value.*scale_uvbar, 0);
    qscale_uvbar(1).Color = color_uvbar;
    qscale_uvbar(2).Color = color_uvbar;
    qscale_uvbar(1).LineWidth = 2;
    qscale_uvbar(2).LineWidth = 2;
    tscale_uvbar = textm(scale_uvbar_text_lat, scale_uvbar_text_lon, scale_uvbar_text, 'Color', color_uvbar, 'FontSize', text_FS);

    % uvbar plot
    skip = 1;
    npts = [0 0 0 0];

    [ubar_rho,vbar_rho,lonred,latred,maskred] = uv_vec2rho_J(ubar,vbar,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    ubar_rho = ubar_rho.*maskred;
    vbar_rho = vbar_rho.*maskred;

    % Adjust vector
    [ubar_rho, vbar_rho, lon_scl] = adjust_vector(g.lon_rho, g.lat_rho, ubar_rho, vbar_rho);

    quvbar = quiverm_J(g.lat_rho(1:interval_uvbar:end, 1:interval_uvbar:end), ...
        g.lon_rho(1:interval_uvbar:end, 1:interval_uvbar:end), ...
        vbar_rho(1:interval_uvbar:end, 1:interval_uvbar:end).*scale_uvbar, ...
        ubar_rho(1:interval_uvbar:end, 1:interval_uvbar:end).*scale_uvbar, ...
        0);

    quvbar(1).Color = color_uvbar;
    quvbar(2).Color = color_uvbar;
    quvbar(1).LineWidth = 2;
    quvbar(2).LineWidth = 2;

    % Wind plot
    mstr_atm = num2str(mm, '%02i');
    yyyy_mm = [ystr, '_', mstr_atm];
    ERA5_filename = ['ERA5_', yyyy_mm, '_a.nc'];
    ERA5_file = [ERA5_filepath, '/', ystr, '/', ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'));
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_time = double(ncread(ERA5_file, 'time'));
    ERA5_uwind = ncread(ERA5_file, 'u10');
    ERA5_vwind = ncread(ERA5_file, 'v10');

    ERA5_timenum = ERA5_time/24 + datenum(1900,1,1);
    tindex = find(ERA5_timenum >= timenum -0.5 & ERA5_timenum < timenum +0.5);

    ERA5_uwind_daily = mean(ERA5_uwind(:,:,tindex),3);
    ERA5_vwind_daily = mean(ERA5_vwind(:,:,tindex),3);

    [ERA5_lat2, ERA5_lon2] = meshgrid(double(ERA5_lat), double(ERA5_lon));

    % Adjust vector
    [ERA5_uwind_daily, ERA5_vwind_daily, lon_scl] = adjust_vector(ERA5_lon2, ERA5_lat2, ERA5_uwind_daily, ERA5_vwind_daily);

    qwind = quiverm_J(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
        ERA5_vwind_daily(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        ERA5_uwind_daily(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
        0);
    qwind(1).Color = color_wind;
    qwind(2).Color = color_wind;
    qwind(1).LineWidth = 2;
    qwind(2).LineWidth = 2;

    qscale_wind = quiverm_J(scale_wind_lat, scale_wind_lon, 0.*scale_wind, scale_wind_value.*scale_wind, 0);
    qscale_wind(1).Color = color_wind;
    qscale_wind(2).Color = color_wind;
    qscale_wind(1).LineWidth = 2;
    qscale_wind(2).LineWidth = 2;
    tscale_wind = textm(scale_wind_text_lat, scale_wind_text_lon, scale_wind_text, 'Color', color_wind, 'FontSize', text_FS);

    uistack(qwind, 'bottom')
    uistack(quvbar, 'bottom')
    uistack(T,'bottom')

    % Make gif
    gifname = ['zeta_uvbar_wind_', map, '_', ystr, '_daily.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == timenum_start
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(T)
    delete(quvbar)
    delete(qscale_uvbar)
    delete(qwind)
    delete(qscale_wind)
end
