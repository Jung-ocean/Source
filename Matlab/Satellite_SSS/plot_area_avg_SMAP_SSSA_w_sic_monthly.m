%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot area-averaged SMAP SSS anomaly with sea ice concentration
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2015:2023;
mm = 6; mstr = num2str(mm, '%02i');

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

region = 'eoshelf';
mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
indmask = eval(['mask_Scott.ind', region]);
[row,col] = ind2sub([1460, 957], indmask);
indmask = sub2ind([957, 1460], col, row); % transpose

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

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

        SSSA(yi) = sum(vari_sat_anomaly_interp(indmask).*area_sat(indmask), 'omitnan')./sum(area_sat(indmask), 'omitnan');
    end
end % yi

load(['/data/jungjih/Observations/Sea_ice/ASI/Fi_ASI_04_', region, '.mat'])

figure; hold on; grid on;
plot(yyyy_all, SSSA, '-o');
ylabel('SSS anomaly, Eastern Bering Sea outer shelf')
yyaxis right
plot(yyyy_all, Fi, '-o');
ylabel('Fraction, Eastern Bering Sea outer shelf')
yyaxis left
ax1 = gca;
ax1.YColor = [0 0.4471 0.7412];

figure; hold on; grid on;
plot(SSSA, Fi, '.k', 'MarkerSize', 25);
xlabel('SSS anomaly, Eastern Bering Sea outer shelf')
ylabel('Fraction, Eastern Bering Sea outer shelf')
