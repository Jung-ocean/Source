%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ARGO BOA SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

vari_str = 'salt';
layer = 1;
yyyy_all = 2015:2023;

% Load grid information
g = grd('BSf');

remove_climate = 1;
if remove_climate == 1
    %climit = [-2 2]; interval = 0.5;
    climit = [-1 1]; interval = 0.2;
    [color, contour_interval] = get_color('redblue', climit, interval);

    titles = 'ARGO BOA SSSA';
    savename = 'ARGO_BOA_SSSA';
else
    climit = [29 34];
    interval = 0.25;
    [color, contour_interval] = get_color('jet', climit, interval);

    titles = 'ARGO BOA SSS';
    savename = 'ARGO_BOA_SSS';
end
unit = 'psu';

mm_all = 1:12;
for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    figure;
    set(gcf, 'Position', [1 200 1400 900])
    t = tiledlayout(3,3);

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);
        title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

        % ARGO BOA
        filepath = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];
        filename = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file = [filepath, filename];
        data = load(file);
        try
            lon = data.lon;
            lat = data.lat;
            vari = data.salt(:,:,1);
        catch
            lon = NaN;
            lat = NaN;
            vari = NaN;
        end

        if remove_climate == 1
            filepath_climate = '/data/jungjih/Observations/ARGO_BOA/climate/';
            filename_climate = ['BOA_Argo_climate_', mstr, '.mat'];
            file_climate = [filepath_climate, filename_climate];
            data_climate = load(file_climate);
            vari_climate = data_climate.salt(:,:,1);

            vari = vari - vari_climate;
        end

        lon = lon - 360;
        latind = find(40 < lat(1,:) & lat(1,:) < 80);
        lonind = find(-250 < lon(:,1) & lon(:,1) < -180);
        lat = lat(lonind, latind);
        lon = lon(lonind, latind);
        vari = vari(lonind, latind);

        % Tile
        nexttile(yi); hold on;

        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k');

        plot_contourf([], lat, lon, vari, color, climit, contour_interval);

        if yi == 1
            c = colorbar;
            c.Layout.Tile = 'east';
            c.Title.String = unit;
            c.FontSize = 15;
        end

        if strcmp(map, 'Gulf_of_Anadyr')
            textm(65.9, -178, [title_str], 'FontSize', 15)
            set(gcf, 'Position', [1 200 1100 900])
        elseif strcmp(map, 'NW_Bering')
            textm(65, -198, [title_str], 'FontSize', 15)
        else
            textm(65, -205, [title_str], 'FontSize', 20)
        end

        title(t, [titles], 'FontSize', 25);
    end

    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    print([savename, '_', mstr, '_monthly'],'-dpng');
end % yi