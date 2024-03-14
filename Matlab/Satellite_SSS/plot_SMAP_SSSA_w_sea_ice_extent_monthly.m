%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMAP SSS anomaly with sea ice extent
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 8; mstr = num2str(mm, '%02i');

mm_sea_ice = 3; msistr = num2str(mm_sea_ice, '%02i');
filepath_monthly = '/data/jungjih/Observations/Sea_ice/NSIDC/shapefiles/shp_extent/';

climit = [-.5 .5];
unit = 'g/kg';

% Load grid information
grd_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
theta_s = 2;
theta_b = 0;
Tcline = 50;
N = 45;
scoord = [theta_s theta_b Tcline N];
Vtransform = 2;
g = roms_get_grid(grd_file,scoord,0,Vtransform);
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

figure;
set(gcf, 'Position', [1 200 1400 900])
tiledlayout(3,3);
% Figure title
ttitle = annotation('textbox', [.22 .85 .60 .15], 'String', ['RSS SMAP SSS anomaly (with ', datestr(datenum(0,mm_sea_ice,1), 'mmm'), ' sea ice extent)']);
ttitle.FontSize = 25;
ttitle.EdgeColor = 'None';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/', ystr, '/'];
    filepath_RSS_70_climatology = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/climatology/'];

    lons_sat = {'lon'};
    lons_360ind = [360];
    lats_sat = {'lat'};
    varis_sat = {'sss_smap'};
    titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)'};
   
    % Satellite
    for si = 1:1
        filepath_sat = filepath_RSS_70;
        filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
        filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

        filepath_sat_climatology = filepath_RSS_70_climatology;
        filepattern_sat_climatology = fullfile(filepath_sat_climatology, (['*climatology_', mstr, '*']));

        filename_sat = dir(filepattern1_sat);
        if isempty(filename_sat)
            filename_sat = dir(filepattern2_sat);
        end
        filename_sat_climatology = dir(filepattern_sat_climatology);

        file_sat = [filepath_sat, filename_sat.name];
        lon_sat = double(ncread(file_sat,lons_sat{si}));
        lat_sat = double(ncread(file_sat,lats_sat{si}));
        vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');

        file_sat_climatology = [filepath_sat_climatology, filename_sat_climatology.name];
        vari_sat_climatology = double(squeeze(ncread(file_sat_climatology,varis_sat{si}))');

        vari_sat_anomaly = vari_sat - vari_sat_climatology;

        if si == 3 || si == 4
            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            vari_sat_anomaly = [vari_sat_anomaly(:,index1) vari_sat_anomaly(:,index2)];
        end
        lon_sat = lon_sat - lons_360ind(si);

        index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
        index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

        vari_sat_anomaly_part = vari_sat_anomaly(index_lat,index_lon);

        [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

        vari_sat_anomaly_interp = griddata(lon_sat2, lat_sat2, vari_sat_anomaly_part, lon,lat);
        mask_sat = ~isnan(vari_sat_anomaly_interp);
        mask_sat_model = (mask_sat./mask_sat).*mask;
        area_sat = area.*mask_sat_model;

        % Tile
        nexttile(yi);

        plot_map(map, 'mercator', 'l')
        hold on;
        contourm(lat, lon, h, [50 200], 'k');
       
        T = pcolorm(lat,lon,vari_sat_anomaly_interp.*mask_sat_model);
        colormap redblue
        uistack(T,'bottom')
        caxis(climit)
        if yi == 1
            c = colorbar;
            c.Layout.Tile = 'east';
            c.Label.String = unit;
        end
        title([title_str])

        % Sea ice extent
        filename_monthly = [filepath_monthly, 'extent_N_', ystr, msistr, '_polygon_v3.0'];

        s = shaperead(filename_monthly);
        x1 = [s.X];
        y1 = [s.Y];
        info = shapeinfo(filename_monthly);
        p1 = info.CoordinateReferenceSystem;
        [lat_monthly,lon_monthly] = projinv(p1,x1,y1);

        p = plotm(lat_monthly, lon_monthly, 'g', 'LineWidth', 2);
        if yyyy == 2016 | 2020 | 2021 | 2023
            p.LineWidth = 2.4;
        end
        %         uistack(f,'bottom');
    end
end % yi

print(strcat('RSS_SMAP_SSSA_', mstr, '_with_', msistr, '_sea_ice_extent'),'-dpng');