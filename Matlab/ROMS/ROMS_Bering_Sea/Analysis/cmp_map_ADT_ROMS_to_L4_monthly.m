%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output seasonal averaged zeta to Satellite L4 monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2019:2022;
mm = 8;

region = 'Gulf_of_Anadyr';

iswind = 0;
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 5;
scale_wind = 0.8;

climit_model = [-40 40];
unit = 'cm';
switch region
    case 'Gulf_of_Anadyr'
        contour_interval = -40:2:40;
    case 'Eastern_Bering'
        contour_interval = -40:5:40;
end

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

% Satellite L4
filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/'];

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

    filename = [case_control, '_', ystr, mstr, '.nc'];
    file = [filepath_control, filename];
    if ~exist(file)
        zeta = NaN;
    else
        zeta = mask.*ncread(file, 'zeta')';
    end
    zeta = zeta - mean(zeta(:), 'omitnan');

    % Figure title
    title(t, ['ADT in ', datestr(timenum, 'mmm')], 'FontSize', 25);

    nexttile(yi)
    plot_map(region, 'mercator', 'l')
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T(1) = pcolorm(g.lat_rho,g.lon_rho,100*zeta); shading flat
    colormap jet
    uistack(T(1),'bottom')
    caxis(climit_model)
    plot_map(region, 'mercator', 'l')

    zeta_contour = zeta;
    zeta_contour(isnan(zeta) == 1) = 1000;
    [cs, h] = contourm(g.lat_rho,g.lon_rho,100*zeta_contour, contour_interval, 'k');
    
    if yi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.Ticks = climit_model(1):10:climit_model(end);
        c.FontSize = 15;
    end

    if strcmp(region, 'Gulf_of_Anadyr')
        textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
        textm(text2_lat, text2_lon, datestr(timenum, 'mmm, yyyy'), 'FontSize', text_FS)
    else
        title(['ROMS (', datestr(timenum, 'mmm, yyyy'), ')'])
    end

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

    % Satellite L4
    filename_CMEMS = ['dt_global_allsat_phy_l4_', ystr, mstr, '.nc'];
    file_CMEMS = [filepath_CMEMS, filename_CMEMS];

    lon_sat = double(ncread(file_CMEMS,'longitude'));
    lat_sat = double(ncread(file_CMEMS,'latitude'));
    vari_sat = double(squeeze(ncread(file_CMEMS,'adt'))');

    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

    lon_sat = lon_sat - 180;

    adt = vari_sat;
    adt = adt - mean(adt(:), 'omitnan');

    % Tile
    nexttile(4+yi);

    plot_map(region, 'mercator', 'l')
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T(2) = pcolorm(lat_sat,lon_sat,100*adt); shading flat
    colormap jet
    uistack(T(2),'bottom')
    caxis(climit_model)
    plot_map(region, 'mercator', 'l')

    adt_contour = adt;
    adt_contour(isnan(adt) == 1) = 1000;
    [cs, h] = contourm(lat_sat,lon_sat,100*adt_contour, contour_interval, 'k');
    
    if strcmp(region, 'Gulf_of_Anadyr')
        textm(text1_lat, text1_lon, 'Sat L4', 'FontSize', text_FS)
        textm(text2_lat, text2_lon, datestr(timenum, 'mmm, yyyy'), 'FontSize', text_FS)
    else
        title(['Sat L4 (', datestr(timenum, 'mmm, yyyy'), ')'])
        set(gcf, 'Position', [1 200 1500 800])
    end

end % yi

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['cmp_map_', vari_str, '_L4_', region, '_monthly_', mstr],'-dpng');