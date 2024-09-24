%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output seasonal averaged zeta to Satellite L2
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2018:2023;

month_all = {'JFM', 'AMJ', 'JAS', 'OND'};

JFM = 1:3;
AMJ = 4:6;
JAS = 7:9;
OND = 10:12;

isice = 0;
aice_value = 0.4;

iswind = 1;
ERA5_filepath = '/data/jungjih/Models/ERA5/monthly/';
interval_wind = 10;
scale_wind = 1;

switch vari_str
    case 'zeta'
        climit_model = [-20 20];
        climit_sat = climit_model;
%         climit_model = [-30 10];
%         climit_sat = [20 60];
        unit = 'cm';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/seasonal/'];

% Satellite SSH Merged L2
filepath_Merged = ['/data/jungjih/Observations/Satellite_SSH/Merged/Merged_MMv5.2_podaac/'];
load([filepath_Merged, 'ADT_monthly.mat'])

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

h1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(month_all)
        month_str = month_all{mi};
        month = eval(month_str);

        filename = [case_control, '_', ystr, '_', month_str, '.nc'];
        file = [filepath_control, filename];
        if ~exist(file)
            zeta = NaN;
        else
            zeta = mask.*ncread(file, 'zeta')';
        end
        zeta = zeta - mean(zeta(:), 'omitnan');

        % Figure title
        title(t, [month_str, ', ', ystr], 'FontSize', 25);

        nexttile(1)
        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
        else
            delete(T(1));
        end

        T(1) = pcolorm(g.lat_rho,g.lon_rho,100*zeta);
        uistack(T(1),'bottom')
        caxis(climit_model)
%         if yi == 1 && mi == 1
%             c = colorbar;
%             c.Title.String = unit;
%             c.Ticks = climit_model(1):10:climit_model(end);
%         end
        title(['ROMS'], 'Interpreter', 'None')

        if iswind == 1
            if yi == 1 && mi == 1
            else
                delete(q);
                delete(qscale);
                delete(tscale);
            end

            ERA5_uwind = zeros;
            ERA5_vwind = zeros;
            for monthi = 1:length(month)
                ERA5_filename = ['ERA5_', ystr, num2str(month(monthi), '%02i'), '.nc'];
                ERA5_file = [ERA5_filepath, ERA5_filename];

                ERA5_lon = ncread(ERA5_file, 'longitude');
                ERA5_lat = ncread(ERA5_file, 'latitude');
                ERA5_uwind_tmp = ncread(ERA5_file, 'u10')';
                ERA5_vwind_tmp = ncread(ERA5_file, 'v10')';

                ERA5_uwind = ERA5_uwind + ERA5_uwind_tmp;
                ERA5_vwind = ERA5_vwind + ERA5_vwind_tmp;
            end
            ERA5_uwind = ERA5_uwind./length(month);
            ERA5_vwind = ERA5_vwind./length(month);

            [ERA5_lon2, ERA5_lat2] = meshgrid(double(ERA5_lon), double(ERA5_lat));

            q = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
                ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
                ERA5_vwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
                ERA5_uwind(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
                0);
            q(1).Color = 'k';
            q(2).Color = 'k';

            qscale = quiverm(64, 160, 0.*scale_wind, 5.*scale_wind, 0);
            qscale(1).Color = 'r';
            qscale(2).Color = 'r';
            tscale = textm(63.5, 160, '5 m/s', 'Color', 'r', 'FontSize', 15);
        end

        % Satellite
        index = find(timevec_all(:,1) == yyyy & ismember(timevec_all(:,2), month) == 1);

        adt = mean(ADT_monthly(index,:));
        adt = adt - mean(adt, 'omitnan');

        % Tile
        nexttile(2);

        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
        else
            delete(T(2));
        end
        T(2) = scatterm(lat_ref, lon_ref, 400, 100*adt, '.');

        uistack(T(2),'bottom')
        caxis(climit_sat)
        if yi == 1 && mi == 1
            c = colorbar;
            c.Title.String = unit;
            c.Ticks = climit_sat(1):10:climit_sat(end);
        end

%         title('MERGED_TP_J1_OSTM_OST_CYCLES_V51', 'Interpreter', 'None')
        title('Satellite L2', 'Interpreter', 'None')

        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        pause(1)
        print(['compare_', vari_str, '_L2_seasonal_', ystr, '_', num2str(mi, '%02i'), '_', month_str],'-dpng');

        % Make gif
        gifname = ['compare_', vari_str, '_L2_seasonal.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if yi == 1 && mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

    end % mi
end % yi