%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot MSLP monthly using ECMWF ERA5
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NE_Pacific';

vari_str = 'msl';
yyyy_all = 2019:2022;
mm = 8;
mstr = num2str(mm, '%02i');

ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';

iswind = 1;

switch map
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
Cd = 1.25e-3;
rhoair = 1.225;

% Figure properties
color = 'jet';
climit = [990 1030];
contour_interval = climit(1):10:climit(2);
unit = 'hPa';
savename = 'mslp';

figure;
if strcmp(map, 'NE_Pacific')
    set(gcf, 'Position', [1 200 1900 450])
else
    set(gcf, 'Position', [1 200 1500 450])
end


t = tiledlayout(1,4);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    ERA5_filename = ['ERA5_', ystr, mstr, '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];
    ERA5_lon = double(ncread(ERA5_file, 'longitude'));
    ERA5_lat = double(ncread(ERA5_file, 'latitude'));
    ERA5_msl = double(ncread(ERA5_file, vari_str)')/100;

    nexttile(yi); hold on;
    plot_map(map, 'mercator', 'l')
    p = pcolorm(ERA5_lat, ERA5_lon, ERA5_msl); shading flat
    colormap(color)
    caxis(climit)
    uistack(p, 'bottom')
    plot_map(map, 'mercator', 'l')

    [cs, h] = contourm(ERA5_lat, ERA5_lon, ERA5_msl, contour_interval, 'k');
    cl = clabelm(cs, h);
    set(cl,'BackgroundColor', 'none', 'Edgecolor', 'none')

    title(['ERA5 MSLP (', title_str, ')'])

    if iswind == 1
        ERA5_uwind = ncread(ERA5_file, 'u10')';
        ERA5_vwind = ncread(ERA5_file, 'v10')';
        speed = sqrt(ERA5_uwind.*ERA5_uwind + ERA5_vwind.*ERA5_vwind);
        sustr = rhoair.*Cd.*speed.*ERA5_uwind;
        svstr = rhoair.*Cd.*speed.*ERA5_vwind;

        [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon), double(ERA5_lat));

        q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
            ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
            svstr(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            sustr(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
            0);
        q(1).Color = 'k';
        q(2).Color = 'k';
        q(1).LineWidth = 2;
        q(2).LineWidth = 2;

        qscale = quiverm(scale_lat, scale_lon, 0.*scale_wind, scale.*scale_wind, 0);
        qscale(1).Color = 'r';
        qscale(2).Color = 'r';
        tscale = textm(scale_text_lat, scale_text_lon, scale_text, 'Color', 'r', 'FontSize', 10);

        title(['ERA5 MSLP with neutral wind stress (', title_str, ')'])
        savename = 'mslp_with_windstress';
    end

    if yi == 4
        c = colorbar;
        c.Title.String = unit;
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');