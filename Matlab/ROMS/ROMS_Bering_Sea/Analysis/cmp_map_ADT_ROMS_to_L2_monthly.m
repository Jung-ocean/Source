%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output seasonal averaged zeta to Satellite L2 monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2019:2022;
mm = 5;

region = 'Gulf_of_Anadyr';

iswind = 1;
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 5;
scale_wind = 0.8;

switch vari_str
    case 'zeta'
        climit_model = [-20 20];
        climit_sat = climit_model;
        %         climit_model = [-30 10];
        %         climit_sat = [20 60];
        unit = 'cm';
end

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 20;

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

% Satellite SSH Merged L2
filepath_Merged = ['/data/jungjih/Observations/Satellite_SSH/Merged/Merged_MMv5.2_podaac/'];
load([filepath_Merged, 'ADT_monthly.mat'])

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
    uistack(T(1),'bottom')
    caxis(climit_model)
    plot_map(region, 'mercator', 'l')
    if yi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.Ticks = climit_model(1):10:climit_model(end);
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
    index = find(timevec_all(:,1) == yyyy & ismember(timevec_all(:,2), mm) == 1);

    adt = ADT_monthly(index,:);
    adt = adt - mean(adt, 'omitnan');

    % Tile
    nexttile(4+yi);

    plot_map(region, 'mercator', 'l')
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    T(2) = scatterm(lat_ref, lon_ref, 50, 100*adt, '.');

    uistack(T(2),'bottom')
    caxis(climit_sat)

    textm(text1_lat, text1_lon, 'Sat L2', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, datestr(timenum, 'mmm, yyyy'), 'FontSize', text_FS)

end % yi

t.TileSpacing = 'compact';
t.Padding = 'compact';

print(['cmp_map_', vari_str, '_L2_monthly_', mstr],'-dpng');