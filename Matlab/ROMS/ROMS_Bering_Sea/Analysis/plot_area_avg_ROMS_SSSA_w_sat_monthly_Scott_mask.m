%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output anomaly through area-averaged with Satellite
% by applying Scott's mask
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2018:2022;
mm_all = 1:12;
depth_shelf = 200; % m
layer = 45;
num_sat = 5;

region = 'eoshelf';
mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
indmask = eval(['mask_Scott.ind', region]);
[row,col] = ind2sub([1460, 957], indmask);
indmask = sub2ind([957, 1460], col, row); % transpose

% mask = g.mask_rho;
% mask(indmask) = 2;
% figure;
% pcolor(g.lon_rho, g.lat_rho, mask); shading interp

isice = 0;
aice_value = 0.4;

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 34.5];
        ylimit_basin = [32.2 34.0];
        climit = [-1 1];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];
filepath_climatology = [filepath_all, case_control, '/climatology/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;

mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

% mask_Bering_Sea_struct = load('mask_Bering_Sea.mat', 'mask_Bering_Sea');
% mask_Bering_Sea = mask_Bering_Sea_struct.mask_Bering_Sea;
% mask = mask.*mask_Bering_Sea;
% area = area.*mask_Bering_Sea;

% mask_RSS_70km_Aug = load('mask_RSS_70km_Aug.mat');
% mask = mask.*mask_RSS_70km_Aug.mask_sat_model;
% area = area.*mask_RSS_70km_Aug.mask_sat_model;

% mask_ind = NaN(size(mask));
% mask_ind(indmask) = 1;
% mask = mask.*mask_ind;
% area = area.*mask_ind;

index_shelf = find(h < depth_shelf);
index_basin = find(h > depth_shelf);

timenum_all = zeros(length(yyyy_all)*length(mm_all),1);
vari_anomaly_shelf = zeros(length(yyyy_all)*length(mm_all),1);
vari_anomaly_basin = zeros(length(yyyy_all)*length(mm_all),1);
vari_sat_anomaly_shelf = zeros(num_sat, length(yyyy_all)*length(mm_all));
vari_sat_anomaly_basin = zeros(num_sat, length(yyyy_all)*length(mm_all));
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/', ystr, '/'];
    filepath_RSS_70_climatology = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/climatology/'];
    filepath_RSS_40 = filepath_RSS_70;
    filepath_RSS_40_climatology = filepath_RSS_70_climatology;
    % CEC SMOS v8.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/monthly/'];
    filepath_CEC_climatology = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/climatology/'];
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];
    filepath_OISSS_climatology = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/climatology/'];
    % CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/', ystr, '/'];
    filepath_CMEMS_climatology = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/climatology/'];
    filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_CEC, filepath_OISSS, filepath_CMEMS};
    filepaths_sat_climatology = {filepath_RSS_70_climatology, filepath_RSS_40_climatology, filepath_CEC_climatology, filepath_OISSS_climatology, filepath_CMEMS_climatology};

    lons_sat = {'lon', 'lon', 'lon', 'longitude', 'lon'};
    lons_360ind = [360, 360, 180, 180, 360];
    lats_sat = {'lat', 'lat', 'lat', 'latitude', 'lat'};
    varis_sat = {'sss_smap', 'sss_smap_40km', 'SSS', 'sss', 'sos'};
    titles_sat = {'RSS SMAP L3 SSS v5.3 (70 km)', 'RSS SMAP L3 SSS v5.3 (40 km)', 'CEC SMOS L3 SSS v9.0', 'ESR OISSS L4 v2.0', 'CMEMS Multi Observation L4 SSS'};

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        % Figure
        if yi == 1 && mi == 1
            h1 = figure; hold on;
            %set(gcf, 'Position', [1 200 1500 750])
            set(gcf, 'Position', [1 200 1400 900])
            t = tiledlayout(2,3);
        else
            delete(ttitle);
        end

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'.nc']));
        filepattern_climatology = fullfile(filepath_climatology,(['*_climatology_',mstr,'.nc']));
        filename_control = dir(filepattern_control);
        filename_climatology = dir(filepattern_climatology);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            file_climatology = [filepath_climatology, filename_climatology.name];

            vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
            vari_climatology = ncread(file_climatology,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
            vari_anomaly = vari_control - vari_climatology;
            if isice == 1
                try
                    aice_mask = ncread(file_control,'aice')';
                    aice_mask(aice_mask >= aice_value) = NaN;
                    aice_mask(aice_mask < aice_value) = 1;
                    mask_with_ice = mask.*aice_mask;
                    area_with_ice = area.*aice_mask;

                    vari_anomaly_shelf(12*(yi-1) + mi) = sum(vari_anomaly(index_shelf).*area_with_ice(index_shelf), 'omitnan')./sum(area_with_ice(index_shelf), 'omitnan');
                    vari_anomaly_basin(12*(yi-1) + mi) = sum(vari_anomaly(index_basin).*area_with_ice(index_basin), 'omitnan')./sum(area_with_ice(index_basin), 'omitnan');
                catch
                    vari_anomaly_shelf(12*(yi-1) + mi) = sum(vari_anomaly(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
                    vari_anomaly_basin(12*(yi-1) + mi) = sum(vari_anomaly(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');
                end
            else
                vari_anomaly_shelf(12*(yi-1) + mi) = sum(vari_anomaly(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
                vari_anomaly_basin(12*(yi-1) + mi) = sum(vari_anomaly(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');
            end % isice

        else
            vari_anomaly = NaN;
            vari_anomaly_shelf(12*(yi-1) + mi) = NaN;
            vari_anomaly_basin(12*(yi-1) + mi) = NaN;
        end

        timenum = datenum(yyyy,mm,15);
        time_title = datestr(timenum, 'mmm, yyyy');
        timenum_all(12*(yi-1) + mi) = timenum;

        % Figure title
        ttitle = annotation('textbox', [.44 .85 .15 .15], 'String', time_title);
        ttitle.FontSize = 25;
        ttitle.EdgeColor = 'None';

        nexttile(1)
        if yi == 1 && mi == 1
            plot_map(map, 'mercator', 'l')
            hold on;
            contourm(lat, lon, h, [50 200], 'k');
        else
            delete(T(1));
        end

        if isice == 1
            try
                T(1) = pcolorm(lat,lon,vari_anomaly.*mask_with_ice);
            catch
                T(1) = pcolorm(lat,lon,vari_anomaly.*mask);
            end
        else
            T(1) = pcolorm(lat,lon,vari_anomaly.*mask);
        end % isice
        colormap redblue
        uistack(T(1),'bottom')
        caxis(climit)
        title('ROMS Dsm_1rnoff', 'Interpreter', 'None')

        % Satellite
        for si = 1:num_sat
            filepath_sat = filepaths_sat{si};
            filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
            filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

            filepath_sat_climatology = filepaths_sat_climatology{si};
            filepattern_sat_climatology = fullfile(filepath_sat_climatology, (['*climatology_', mstr, '*']));

            filename_sat = dir(filepattern1_sat);
            if isempty(filename_sat)
                filename_sat = dir(filepattern2_sat);
            end
            filename_sat_climatology = dir(filepattern_sat_climatology);

            if isempty(filename_sat)
                vari_sat_anomaly_shelf(si,12*(yi-1) + mi) = NaN;
                vari_sat_anomaly_basin(si,12*(yi-1) + mi) = NaN;
                vari_sat_anomaly_interp = NaN;
                mask_sat_model = NaN;
            else
                file_sat = [filepath_sat, filename_sat.name];
                lon_sat = double(ncread(file_sat,lons_sat{si}));
                lat_sat = double(ncread(file_sat,lats_sat{si}));
                vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

                file_sat_climatology = [filepath_sat_climatology, filename_sat_climatology.name];
                vari_sat_climatology = double(squeeze(ncread(file_sat_climatology,varis_sat{si}))');

                vari_sat_anomaly = vari_sat - vari_sat_climatology;

                %if si == 4
                if si == 3 || si == 4
                    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                    vari_sat_anomaly = [vari_sat_anomaly(:,index1) vari_sat_anomaly(:,index2)];
                end
                lon_sat = lon_sat - lons_360ind(si);

                if isice == 1 && si == 5
                    aice_mask_sat = ncread(file_sat, 'sea_ice_fraction')';

                    aice_mask_sat(aice_mask_sat >= aice_value) = NaN;
                    aice_mask_sat(aice_mask_sat < aice_value) = 1;

                    vari_sat_anomaly = vari_sat_anomaly.*aice_mask_sat;
                end

                index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
                index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

                vari_sat_anomaly_part = vari_sat_anomaly(index_lat,index_lon);

                [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

                vari_sat_anomaly_interp = griddata(lon_sat2, lat_sat2, vari_sat_anomaly_part, lon,lat);
                mask_sat = ~isnan(vari_sat_anomaly_interp);
                mask_sat_model = (mask_sat./mask_sat).*mask;
                area_sat = area.*mask_sat_model;
                vari_sat_anomaly_shelf(si,12*(yi-1) + mi) = sum(vari_sat_anomaly_interp(index_shelf).*area_sat(index_shelf), 'omitnan')./sum(area_sat(index_shelf), 'omitnan');
                vari_sat_anomaly_basin(si,12*(yi-1) + mi) = sum(vari_sat_anomaly_interp(index_basin).*area_sat(index_basin), 'omitnan')./sum(area_sat(index_basin), 'omitnan');
            end

            % Tile
            nexttile(si+1);

            if yi == 1 && mi == 1
                plot_map(map, 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(si+1));
            end
            T(si+1) = pcolorm(lat,lon,vari_sat_anomaly_interp.*mask_sat_model);
            colormap redblue
            uistack(T(si+1),'bottom')
            caxis(climit)
            if yi == 1 && mi == 1 && si == num_sat
                c = colorbar;
                c.Layout.Tile = 'east';
                c.Label.String = unit;
            end

            title(titles_sat{si}, 'Interpreter', 'None')

        end

        pause(1)
%         print(strcat('compare_surface_', vari_str, '_anomaly_satellite_monthly_', datestr(timenum, 'yyyymm')),'-dpng');

        % Make gif
        gifname = ['compare_surface_', vari_str, '_anomaly_satellite_monthly.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if yi == 1 && mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

        disp([ystr, mstr, '...'])
    end % mi
end % yi
timevec = datevec(timenum_all);
%xtic_list = datenum(unique(timevec(:,1)), unique(timevec(:,2)), 15);
dfdfd
% Plot
h1 = figure; hold on; grid on;
%set(gcf, 'Position', [1 1 1500 400])
set(gcf, 'Position', [1 1 850 500])
t = tiledlayout(1,1);

%ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', ['Area-averaged ', vari_str]);
%ttitle.FontSize = 25;
%ttitle.EdgeColor = 'None';

% Tile 1
nexttile(1); hold on; grid on
T1p1 = plot(timenum_all, vari_anomaly_shelf, '-ok', 'LineWidth', 2);
for si = 1:num_sat
    T1ps(si) = plot(timenum_all, vari_sat_anomaly_shelf(si,:), '-o', 'LineWidth', 2);
end
xticks(timenum_all);
xlim([timenum_all(7) timenum_all(end-1)])
datetick('x', 'mmm, yyyy', 'keepticks', 'keeplimits')
ylim(ylimit_shelf);
ylabel(unit)
title(['Outer shelf area averaged (50 - ', num2str(depth_shelf), ' m)'])
%title(['Shelf area averaged (< ', num2str(depth_shelf), ' m)'])
l = legend([T1p1, T1ps], [case_control, titles_sat], 'Interpreter', 'none');
l.NumColumns = 2;
l.Location = 'Northwest';
%l.FontSize = 15;

% % Tile 2
% nexttile(2); hold on; grid on
% T2p1 = plot(timenum_all, vari_control_basin, '-ok', 'LineWidth', 2);
% for si = 1:num_sat
%     T2ps(si) = plot(timenum_all, vari_sat_basin(si,:), '-o', 'LineWidth', 2);
% end
% xticks(timenum_all);
% datetick('x', 'mmm, yyyy', 'keepticks')
% ylim(ylimit_basin);
% ylabel(unit)
% title(['Basin area averaged (> ', num2str(depth_shelf), ' m)'])
% %l = legend([T2p1, T2p2, T2ps], [case_control, case_exp, titles_sat], 'Interpreter', 'none');
% %l.Location = 'SouthWest';
% %l.FontSize = 15;

pause(1)
print(strcat('compare_area_averaged_', vari_str, '_with_Satellite_monthly'),'-dpng');