%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot zeta (ROMS) with ice concentration (ROMS), 
% ice velocity (ROMS) and wind (ERA5) daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
map = 'Gulf_of_Anadyr';
startdate = datenum(2018,7,1);

ispng = 1;

yyyy = 2022; 
ystr = num2str(yyyy);
mm = 4;
mstr = num2str(mm, '%02i');

g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
area=dx.*dy;

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
        text_FS = 25;
        
        color_ice = [1.0000 0.0745 0.6510];
        interval_ice = 30;
        scale_ice = 2;
        scale_ice_value = 0.2;
        scale_ice_lat = text_ice_lat-0.5;
        scale_ice_lon = text_ice_lon;
        scale_ice_text = '20 cm/s';
        scale_ice_text_lat = scale_ice_lat-0.4;
        scale_ice_text_lon = text_ice_lon;
        % Adjust vector
        [scale_ice_value, scale_ice_v, lon_scl] = adjust_vector(scale_ice_lon, scale_ice_lat, scale_ice_value, 0);

        color_wind = 'k';
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
interval = 5;
climit = [-40 20];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
cutoff_aice = 0.15;
cutoff_hice = 0.1;
unit = ['cm'];
savename = 'zeta_w_aice_uvice_wind';

h1 = figure;
set(gcf, 'Position', [1 200 1300 800])
title(['Sea level (color), ice velocity (magenta), and 10 m wind (black)'], 'FontSize', 15);

for di = 1:eomday(1,mm)
    dd = di; dstr = num2str(dd, '%02i');

    timenum = datenum(yyyy,mm,dd);
    title_str = datestr(timenum, 'mmm dd, yyyy');

    cla; hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    filenum = timenum - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];
    ot = ncread(file, 'ocean_time');
    zeta = ncread(file, 'zeta')';
    aice = ncread(file, 'aice')';
    hice = ncread(file, 'hice')';
    uice = ncread(file, 'uice')';
    vice = ncread(file, 'vice')';

    vari = zeta*100;

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

    icf = aice;
    icf(size(g.lat_rho,1),1)=0.5;
    ind = find(isnan(icf)==1);
    icf(ind)=0.0;
    icf = icf*1;

    set(T,'alphadata',1-icf,'AlphaDataMapping','none','facealpha','flat','edgecolor','none');

    if di == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval;
        c.FontSize = 15;
    end

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
    tscale = textm(scale_ice_text_lat, scale_ice_text_lon, scale_ice_text, 'Color', color_ice, 'FontSize', text_FS);

    % Wind plot
    timenum = ot/60/60/24 + datenum(1968,5,23);
    yyyy_mm = datestr(timenum, 'yyyy_mm');

    ERA5_filename = ['ERA5_', yyyy_mm, '_a.nc'];
    ERA5_file = [ERA5_filepath, '/', ystr, '/', ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'));
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_time = double(ncread(ERA5_file, 'time'));
    ERA5_uwind = ncread(ERA5_file, 'u10');
    ERA5_vwind = ncread(ERA5_file, 'v10');

    ERA5_timenum = ERA5_time/24 + datenum(1900,1,1);
    tindex = find(ERA5_timenum >= timenum -0.5 & ERA5_timenum < timenum +0.5);
    ERA5_uwind_daily = mean(ERA5_uwind(:,:,tindex),3)';
    ERA5_vwind_daily = mean(ERA5_vwind(:,:,tindex),3)';

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
    tscale = textm(scale_wind_text_lat, scale_wind_text_lon, scale_wind_text, 'Color', color_wind, 'FontSize', text_FS);

    uistack(qwind, 'bottom')
%     uistack(qice, 'bottom')
    uistack(T,'bottom')

    if strcmp(map, 'Gulf_of_Anadyr')
%         t1 = textm(text_ice_lat, text_ice_lon, 'Sea ice', 'Color', color_ice, 'FontSize', text_FS);
        t2 = textm(text_wind_lat, text_wind_lon, 'Wind', 'Color', color_wind, 'FontSize', text_FS);

        t3 = textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS);
    else
        title(['ROMS (', title_str, ')'])
    end

    if ispng == 1
        print([savename, '_', datestr(timenum, 'yyyymmdd')], '-dpng')
    end

% Make gif
gifname = [savename, '_', ystr, mstr, '_daily.gif'];

frame = getframe(h1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if di == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

end % di