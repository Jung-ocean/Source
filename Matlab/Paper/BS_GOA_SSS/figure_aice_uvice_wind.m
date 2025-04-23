clear; clc; close all

exp = 'Dsm4';
map = 'Gulf_of_Anadyr';
startdate = datenum(2018,7,1);

yyyy_all = 2021:2022;
labels = {'a', 'd', 'b', 'e', 'c', 'f'};
li = 0;

% mm = 3; % 4
% dd = 10; % 30

g = grd('BSf');

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/ERA5/';

switch map
    case 'Gulf_of_Anadyr'
        text_ice_lat = 66.1;
        text_ice_lon = -184.8;

        text_wind_lat = 63.7;
        text_wind_lon = -184.8;
                     
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 12;
        
        color_ice = [1.0000 0.0745 0.6510];
        interval_ice = 30;
        scale_ice = 3;
        scale_ice_value = 0.2;
        scale_ice_lat = text_ice_lat-0.5;
        scale_ice_lon = text_ice_lon;
        scale_ice_text = '20 cm/s';
        scale_ice_text_lat = scale_ice_lat-0.4;
        scale_ice_text_lon = text_ice_lon;
        % Adjust vector
        [scale_ice_value, scale_ice_v, lon_scl] = adjust_vector(scale_ice_lon, scale_ice_lat, scale_ice_value, 0);

        color_wind = [0.0588 1.0000 1.0000];
        interval_wind = 6;
        scale_wind = 0.2;
        scale_wind_value = 3;
        scale_wind_lat = text_wind_lat-0.5;
        scale_wind_lon = text_wind_lon;
        scale_wind_text = '3 m/s';
        scale_wind_text_lat = scale_wind_lat-0.4;
        scale_wind_text_lon = text_wind_lon;
        % Adjust vector
        [scale_wind_value, scale_wind_v, lon_scl] = adjust_vector(scale_wind_lon, scale_wind_lat, scale_wind_value, 0);
end

% Figure properties
interval = 0.1;
climit = [0 1];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = gray(num_color);
unit = '';
cutoff_aice = 0.15;

f = figure;
set(gcf, 'Position', [1 200 1500 600])

for mi = 1:3

    if mi == 1
        mm = 4;
        dd = 2;
    elseif mi == 2
        mm = 4;
        dd = 10;
    else
        mm = 4;
        dd = 30;
    end

for yi = 1:length(yyyy_all)
    li = li+1;
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    timenum_all = datenum(yyyy,mm,dd)-3:datenum(yyyy,mm,dd)+3;

    zeta_sum = zeros;
    aice_sum = zeros;
    uice_sum = zeros;
    vice_sum = zeros;
    for ti = 1:length(timenum_all)
        timenum = timenum_all(ti);
        title_str = [datestr(datenum(yyyy,mm,dd)-3, 'mmm dd'), '-', datestr(datenum(yyyy,mm,dd)+3, 'mmm dd')];

        filenum = timenum - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = [exp, '_avg_', fstr, '.nc'];
        file = [filepath, filename];
        ot = ncread(file, 'ocean_time');
        if ti == 1
            ot_first = ot;
        elseif ti == length(timenum_all)
            ot_end = ot;
        end
        zeta_tmp = ncread(file, 'zeta')';
        aice_tmp = ncread(file, 'aice')';
        uice_tmp = ncread(file, 'uice')';
        vice_tmp = ncread(file, 'vice')';

        zeta_sum = zeta_sum + zeta_tmp;
        aice_sum = aice_sum + aice_tmp;
        uice_sum = uice_sum + uice_tmp;
        vice_sum = vice_sum + vice_tmp;
    end
    zeta = zeta_sum./length(timenum_all);
    aice = aice_sum./length(timenum_all);
    uice = uice_sum./length(timenum_all);
    vice = vice_sum./length(timenum_all);

    vari = aice;

    subplot('Position', [.05+.2*(mi-1) .55-.45*(yi-1) .2 .4]); hold on;
    plot_map(map, 'mercator', 'l')
    text(-0.16, 1.55, labels{li}, 'FontSize', 20)
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);
    
%     [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    T=pcolorm(g.lat_rho,g.lon_rho,vari);
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')
    plot_map(map, 'mercator', 'l')
   
    % Sea ice velocity plot
    skip = 1;
    npts = [0 0 0 0];

    [uice_rho,vice_rho,lonred,latred,maskred] = uv_vec2rho(uice,vice,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    uice_rho = uice_rho.*maskred;
    vice_rho = vice_rho.*maskred;

    % Adjust vector
    [uice_rho, vice_rho, lon_scl] = adjust_vector(g.lon_rho, g.lat_rho, uice_rho, vice_rho);

    uice_rho(aice < cutoff_aice) = NaN;
    vice_rho(aice < cutoff_aice) = NaN;

    qice = quiverm_J(g.lat_rho(1:interval_ice:end, 1:interval_ice:end), ...
        g.lon_rho(1:interval_ice:end, 1:interval_ice:end), ...
        vice_rho(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
        uice_rho(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
        0);
    
    qice(1).Color = color_ice;
    qice(2).Color = color_ice;
    qice(1).LineWidth = 2;
    qice(2).LineWidth = 2;
    
    qscale = quiverm_J(scale_ice_lat, scale_ice_lon, 0.*scale_ice, scale_ice_value.*scale_ice, 0);
    qscale(1).Color = color_ice;
    qscale(2).Color = color_ice;
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
    tscale = textm(scale_ice_text_lat, scale_ice_text_lon, scale_ice_text, 'Color', color_ice, 'FontSize', 10);

    % Wind plot
    timenum_first = ot_first/60/60/24 + datenum(1968,5,23);
    mm_first = str2num(datestr(timenum_first, 'mm'));
    timenum_end = ot_end/60/60/24 + datenum(1968,5,23);
    mm_end = str2num(datestr(timenum_end, 'mm'));
    
    tlength = zeros;
    ERA5_uwind_sum = zeros;
    ERA5_vwind_sum = zeros;
    if mm_first ~= mm_end
        for mm_atm = mm_first:mm_end
            mstr_atm = num2str(mm_atm, '%02i');
            yyyy_mm = [ystr, '_', mstr_atm];
            ERA5_filename = ['ERA5_', yyyy_mm, '_a.nc'];
            ERA5_file = [ERA5_filepath, '/', ystr, '/', ERA5_filename];
            ERA5_lon = double(ncread(ERA5_file, 'longitude'));
            ERA5_lat = double(ncread(ERA5_file, 'latitude'));
            ERA5_time = double(ncread(ERA5_file, 'time'));
            ERA5_uwind = ncread(ERA5_file, 'u10');
            ERA5_vwind = ncread(ERA5_file, 'v10');

            ERA5_timenum = ERA5_time/24 + datenum(1900,1,1);
            tindex = find(ERA5_timenum >= timenum_first -0.5 & ERA5_timenum < timenum_end +0.5);
            tlength = tlength+length(tindex);

            ERA5_uwind_sum = ERA5_uwind_sum + sum(ERA5_uwind(:,:,tindex),3)';
            ERA5_vwind_sum = ERA5_vwind_sum + sum(ERA5_vwind(:,:,tindex),3)';
        end
    else
        mstr_atm = num2str(mm_first, '%02i');
        yyyy_mm = [ystr, '_', mstr_atm];
        ERA5_filename = ['ERA5_', yyyy_mm, '_a.nc'];
        ERA5_file = [ERA5_filepath, '/', ystr, '/', ERA5_filename];
        ERA5_lon = double(ncread(ERA5_file, 'longitude'));
        ERA5_lat = double(ncread(ERA5_file, 'latitude'));
        ERA5_time = double(ncread(ERA5_file, 'time'));
        ERA5_uwind = ncread(ERA5_file, 'u10');
        ERA5_vwind = ncread(ERA5_file, 'v10');

        ERA5_timenum = ERA5_time/24 + datenum(1900,1,1);
        tindex = find(ERA5_timenum >= timenum_first -0.5 & ERA5_timenum < timenum_end +0.5);
        tlength = tlength+length(tindex);

        ERA5_uwind_sum = ERA5_uwind_sum + sum(ERA5_uwind(:,:,tindex),3)';
        ERA5_vwind_sum = ERA5_vwind_sum + sum(ERA5_vwind(:,:,tindex),3)';
    end
    ERA5_uwind_daily = ERA5_uwind_sum./tlength;
    ERA5_vwind_daily = ERA5_vwind_sum./tlength;

    latind = find(ERA5_lat < max(max(g.lat_rho)) & ERA5_lat > min(min(g.lat_rho)));
    lonind = find(ERA5_lon < max(max(g.lon_rho)) & ERA5_lon > min(min(g.lon_rho)));
    ERA5_uwind_daily = ERA5_uwind_daily(latind, lonind);
    ERA5_vwind_daily = ERA5_vwind_daily(latind, lonind);

    [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon(lonind)), double(ERA5_lat(latind)));

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
    
    qscale = quiverm_J(scale_wind_lat, scale_wind_lon, 0.*scale_wind, scale_wind_value.*scale_wind, 0);
    qscale(1).Color = color_wind;
    qscale(2).Color = color_wind;
    qscale(1).LineWidth = 2;
    qscale(2).LineWidth = 2;
    tscale = textm(scale_wind_text_lat, scale_wind_text_lon, scale_wind_text, 'Color', color_wind, 'FontSize', 10);

    uistack(qwind, 'bottom')
    uistack(qice, 'bottom')
    uistack(T,'bottom')

    if strcmp(map, 'Gulf_of_Anadyr')
        t1 = textm(text_ice_lat, text_ice_lon, 'Sea ice', 'Color', color_ice, 'FontSize', text_FS);
        t2 = textm(text_wind_lat, text_wind_lon, 'Wind', 'Color', color_wind, 'FontSize', text_FS);
    end

    t3 = textm(text2_lat+0.1, text2_lon-.4, [title_str], 'FontSize', 12);
    t4 = textm(text2_lat-0.5, text2_lon+2.4, [ystr], 'FontSize', 12);

    if yi == 1
        mlabel off
        if mi ~= 1
            plabel off
        end
    else
        if mi ~= 1
            plabel off
        end
    end

end % yi
end % mi

c = colorbar('Position', [.65 .1 .01 .85]);
c.Title.String = unit;
c.FontSize = 12;
dd
exportgraphics(gcf,'figure_aice_uvice_wind.png','Resolution',150)