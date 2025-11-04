%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'zeta';
yyyy_all = 2019:2023;
mm = 1;
mstr = num2str(mm, '%02i');

iswind = 1;
ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/ERA5/';

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Load grid information
g = grd('BSf');

% Figure properties
climit = [-30 10];
interval = 2.5;
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'cm';
savename = 'zeta';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;

        color_wind = 'k';
        interval_wind = 5;
        scale_wind = .2;

        scale_wind_value = 5;
        scale_wind_lat = 63.5;
        scale_wind_lon = -184.8;
        scale_wind_text = [num2str(scale_wind_value), ' m/s'];
        scale_wind_text_lat = 63;
        scale_wind_text_lon = -184.8;

    case 'Eastern_Bering'
        text1_lat = 65.7;
        text1_lon = -184.8;
        text2_lat = 65.7;
        text2_lon = -166;
        text_FS = 15;

        interval_wind = 50;
        scale_wind = 10;

        scale_wind_value = 0.2;
        scale_wind_lat = 62.5;
        scale_wind_lon = -162.5;
        scale_wind_text = '0.2 N/m^2';
        scale_wind_text_lat = 62;
        scale_wind_text_lon = -162.5;
end
% Adjust vector
[scale_wind_value, scale_wind_v, lon_scl] = adjust_vector(scale_wind_lon, scale_wind_lat, scale_wind_value, 0);

figure;
set(gcf, 'Position', [1 200 1800 600])
t = tiledlayout(1,5);
% Figure title
title(t, ['Sea level (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    zeta = 100*ncread(file, 'zeta'); % m -> cm
    
    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    %     p = pcolorm(g.lat_rho, g.lon_rho, zeta.*g.mask_rho./g.mask_rho); shading flat
    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    zeta(zeta < climit(1)) = climit(1);
    [cs, h] = contourf(x, y, zeta, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(h, 'bottom')
    plot_map(map, 'mercator', 'l')

    if yi == length(yyyy_all)
        c = colorbar;
        c.Title.String = unit;
    end
    
    textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    if iswind == 1
        savename = 'zeta_w_wind';

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

        ERA5_uwind_monthly = mean(ERA5_uwind,3);
        ERA5_vwind_monthly = mean(ERA5_vwind,3);

        [ERA5_lat2, ERA5_lon2] = meshgrid(double(ERA5_lat), double(ERA5_lon));

        % Adjust vector
        [ERA5_uwind_monthly, ERA5_vwind_monthly, lon_scl] = adjust_vector(ERA5_lon2, ERA5_lat2, ERA5_uwind_monthly, ERA5_vwind_monthly);

        qwind = quiverm_J(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_vwind_monthly(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            ERA5_uwind_monthly(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
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
        uistack(h, 'bottom')
    end

end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', mstr, '_monthly'],'-dpng');