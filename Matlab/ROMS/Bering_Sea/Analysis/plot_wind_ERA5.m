function plot_wind_ERA5(region, yyyy, mm, color, isscale)

[lon_lim, lat_lim] = load_domain(region);

if yyyy == 9999
    ystr = 'climate';
    ERA5_filepath = '/data/jungjih/Models/ERA5/climate/';
    entire_title_str = ['Climate wind (2014-2023)'];
else
    ystr = num2str(yyyy);
    ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
end
mstr = num2str(mm, '%02i');

switch region
    case 'Bering'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 10;

        interval_wind = 10;
        scale_wind = 0.5;

        scale = 3;
        scale_lat = 64;
        scale_lon = -205;
        scale_text = [num2str(scale), ' m/s'];
        scale_text_lat = 63;
        scale_text_lon = -205;
    case 'NW_Bering'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = text1_lat;
        text2_lon = -178;
        text_FS = 15;

        interval_wind = 10;
        scale_wind = 0.5;

        scale = 3;
        scale_lat = 64.5;
        scale_lon = -197.5;
        scale_text = [num2str(scale), ' m/s'];
        scale_text_lat = scale_lat-.5;
        scale_text_lon = scale_lon;
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;

        interval_wind = 4;
        scale_wind = 0.5;

        scale = 3;
        scale_lat = 64;
        scale_lon = -184.5;
        scale_text = '3 m/s';
        scale_text_lat = 63.5;
        scale_text_lon = -184.5;
    case 'Eastern_Bering'
        interval_wind = 5;
        scale_wind = 15;

        scale = 0.2;
        scale_lat = 66;
        scale_lon = -184.5;
        scale_text = '0.2 N/m^2';
        scale_text_lat = 65.5;
        scale_text_lon = -184.5;
    case 'NE_Pacific'
        interval_wind = 10;
        scale_wind = 40;

        scale = 0.2;
        scale_lat = 66;
        scale_lon = -205;
        scale_text = '0.2 N/m^2';
        scale_text_lat = 64;
        scale_text_lon = -205;
end
[scalex, scaley, lon_scl] = adjust_vector(scale_lon, scale_lat, scale, scale);

ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
ERA5_file = [ERA5_filepath, ERA5_filename];
ERA5_lon = double(ncread(ERA5_file, 'longitude'));
ERA5_lat = double(ncread(ERA5_file, 'latitude'));
ERA5_uwind = ncread(ERA5_file, 'u10');
ERA5_vwind = ncread(ERA5_file, 'v10');

latind = find(ERA5_lat < max(lat_lim) & ERA5_lat > min(lat_lim));
lonind = find(ERA5_lon-360 < max(lon_lim) & ERA5_lon-360 > min(lon_lim));
ERA5_uwind = ERA5_uwind(lonind, latind);
ERA5_vwind = ERA5_vwind(lonind, latind);
[ERA5_lat2, ERA5_lon2] = meshgrid(ERA5_lat(latind), ERA5_lon(lonind));

% Adjust vector scale according to lon, lat
[ERA5_uwind, ERA5_vwind, lon_scl] = adjust_vector(ERA5_lon2, ERA5_lat2, ERA5_uwind, ERA5_vwind);

q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
    ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
    ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
    ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
    0);
q(1).Color = color;
q(2).Color = color;
q(1).LineWidth = 2;
q(2).LineWidth = 2;
%     uistack(q, 'bottom')

if isscale == 1
    qscalex = quiverm_J(scale_lat, scale_lon, 0.*scale_wind, scalex.*scale_wind, 0);
    qscalex(1).Color = 'r';
    qscalex(2).Color = 'r';
    qscalex(1).LineWidth = 2;
    qscalex(2).LineWidth = 2;
    qscaley = quiverm_J(scale_lat, scale_lon, scaley.*scale_wind, 0.*scale_wind, 0);
    qscaley(1).Color = 'r';
    qscaley(2).Color = 'r';
    qscaley(1).LineWidth = 2;
    qscaley(2).LineWidth = 2;

    tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', text_FS);
end

end