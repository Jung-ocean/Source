%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output anomaly through area-averaged to Satellite
% by applying mask
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2018:2022;
mm_all = 1:12;
depth_shelf = 200; % m
layer = 45;
num_sat = 5;

isice = 0;
aice_value = 0.4;

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 34.5];
        ylimit_basin = [32.2 34.0];
        climit = [-0.5 0.5];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];
filepath_climate = [filepath_all, case_control, '/climate/'];

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
% area = dx.*dy.*mask.*mask_Bering_Sea;
%
% mask_RSS_70km_Aug = load('mask_RSS_70km_Aug.mat');
% mask = mask.*mask_RSS_70km_Aug.mask_sat_model;
% area = area.*mask_RSS_70km_Aug.mask_sat_model;

index_shelf = find(h < depth_shelf);
index_basin = find(h > depth_shelf);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/monthly/', ystr, '/'];
    filepath_RSS_70_climate = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/climate/'];
    filepath_RSS_40 = filepath_RSS_70;
    filepath_RSS_40_climate = filepath_RSS_70_climate;
    % JPL SMAP v5.0 (https://podaac.jpl.nasa.gov/dataset/SMAP_JPL_L3_SSS_CAP_8DAY-RUNNINGMEAN_V5)
    %filepath_JPL = ['/data/jungjih/Observations/Satellite_SSS/BS/JPL/monthly/'];
    % CEC SMOS v9.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];
    filepath_CEC_climate = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/climate/'];
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];
    filepath_OISSS_climate = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/climate/'];
    % CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/', ystr, '/'];
    filepath_CMEMS_climate = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/climate/'];
    filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_CEC, filepath_OISSS, filepath_CMEMS};
    filepaths_sat_climate = {filepath_RSS_70_climate, filepath_RSS_40_climate, filepath_CEC_climate, filepath_OISSS_climate, filepath_CMEMS_climate};

    % lons_sat = {'lon', 'lon', 'longitude', 'longitude', 'lon'};
    % lons_360ind = [360, 360, 0, 180, 360];
    % lats_sat = {'lat', 'lat', 'latitude', 'latitude', 'lat'};
    % varis_sat = {'sss_smap', 'sss_smap_40km', 'sss', 'sss', 'sos'};
    % titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)', 'RSS SMAP L3 SSS v5.3 8-day MA (40 km)', 'JPL SMAP L3 SSS v5.0 8-day MA (60 km)', 'OISSS L4 v2.0 7-day decorr time scale', 'CMEMS Multi Observation L4 SSS'};

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
            set(gcf, 'Position', [1 200 1500 750])
            t = tiledlayout(2,3);
        end

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
        else
            vari_control = NaN;
        end

        filepattern_climate = fullfile(filepath_climate,(['*climatology_',mstr,'*.nc']));
        filename_climate = dir(filepattern_climate);
        file_control = [filepath_climate, filename_climate.name];
        vari_climate = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';

        timenum = datenum(yyyy,mm,15);
        time_title = datestr(timenum, 'mmm, yyyy');
        timenum_all(12*(yi-1) + mi) = timenum;

        % Figure title
        title(t, ['SSS Anomaly (', time_title, ')'], 'FontSize', 25)

        nexttile(1)
        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(lat, lon, h, [50 200], 'k');
        else
            delete(T(1));
        end

        T(1) = pcolorm(lat,lon,(vari_control-vari_climate).*mask);
        colormap redblue
        uistack(T(1),'bottom')
        caxis(climit)
        title('ROMS Dsm2_spng', 'Interpreter', 'None')

        % Satellite
        for si = 1:num_sat
            filepath_sat = filepaths_sat{si};
            filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
            filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

            filename_sat = dir(filepattern1_sat);
            if isempty(filename_sat)
                filename_sat = dir(filepattern2_sat);
            end

            filepath_sat_climate = filepaths_sat_climate{si};
            filepattern_sat_climate = fullfile(filepath_sat_climate, (['*climatology_', mstr, '*.nc']));
            filename_sat_climate = dir(filepattern_sat_climate);

            if isempty(filename_sat)
                vari_sat_interp = NaN;
            else
                file_sat = [filepath_sat, filename_sat.name];
                lon_sat = double(ncread(file_sat,lons_sat{si}));
                lat_sat = double(ncread(file_sat,lats_sat{si}));
                vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

                file_sat_climate = [filepath_sat_climate, filename_sat_climate.name];
                vari_sat_climate = double(squeeze(ncread(file_sat_climate,varis_sat{si}))');
                if si == 3 || si == 4
                    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
                    vari_sat_climate = [vari_sat_climate(:,index1) vari_sat_climate(:,index2)];
                end
                lon_sat = lon_sat - lons_360ind(si);

                index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
                index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

                vari_sat_part = vari_sat(index_lat,index_lon);
                vari_sat_climate_part = vari_sat_climate(index_lat,index_lon);

                [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

                vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
                vari_sat_climate_interp = griddata(lon_sat2, lat_sat2, vari_sat_climate_part, lon,lat);
            end

            % Tile
            nexttile(si+1);

            if yi == 1 && mi == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(si+1));
            end
            T(si+1) = pcolorm(lat,lon,vari_sat_interp - vari_sat_climate_interp);
            colormap redblue
            uistack(T(si+1),'bottom')
            caxis(climit)
            if yi == 1 && mi == 1 && si == num_sat
                c = colorbar;
                c.Layout.Tile = 'east';
                c.Title.String = unit;
            end

            title(titles_sat{si}, 'Interpreter', 'None')

        end

        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        pause(1)
        print(strcat('compare_surface_', vari_str, '_anomaly_satellite_monthly_', datestr(timenum, 'yyyymm')),'-dpng');

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