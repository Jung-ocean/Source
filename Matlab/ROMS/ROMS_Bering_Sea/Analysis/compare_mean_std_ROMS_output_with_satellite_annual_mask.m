%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output through annual mean and standard deviation
% with Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy = 2022; ystr = num2str(yyyy);
mm_all = 1:12;
depth_shelf = 200; % m
layer = 45;
num_sat = 5;

isice = 1;
aice_value = 0.4;

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 34.5];
        ylimit_basin = [32.2 34.0];
        climit = [31.5 33.5];
        climit_std = [0 .5];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm1_rnoff';
filepath_control = [filepath_all, case_control, '/monthly/'];

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
mask = g.mask_rho./g.mask_rho;
%mask_Bering_Sea_struct = load('mask_Bering_Sea.mat', 'mask_Bering_Sea');
%mask_Bering_Sea = mask_Bering_Sea_struct.mask_Bering_Sea;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
%mask = mask.*mask_Bering_Sea;
%area = dx.*dy.*mask.*mask_Bering_Sea;

%mask_RSS_70km_Aug = load('mask_RSS_70km_Aug.mat');
%mask = mask.*mask_RSS_70km_Aug.mask_sat_model;
%area = area.*mask_RSS_70km_Aug.mask_sat_model;

%index_shelf = find(h < depth_shelf);
%index_basin = find(h > depth_shelf);

% Satellite SSS
% RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/', ystr, '/'];
filepath_RSS_40 = filepath_RSS_70;
% JPL SMAP v5.0 (https://podaac.jpl.nasa.gov/dataset/SMAP_JPL_L3_SSS_CAP_8DAY-RUNNINGMEAN_V5)
filepath_JPL = ['/data/jungjih/Observations/Satellite_SSS/BS/JPL/monthly/'];
% OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];
% CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/', ystr, '/'];
filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_JPL, filepath_OISSS, filepath_CMEMS};

lons_sat = {'lon', 'lon', 'longitude', 'longitude', 'lon'};
lons_360ind = [360, 360, 0, 180, 360];
lats_sat = {'lat', 'lat', 'latitude', 'latitude', 'lat'};
varis_sat = {'sss_smap', 'sss_smap_40km', 'sss', 'sss', 'sos'};
titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)', 'RSS SMAP L3 SSS v5.3 8-day MA (40 km)', 'JPL SMAP L3 SSS v5.0 8-day MA (60 km)', 'OISSS L4 v2.0 7-day decorr time scale', 'CMEMS Multi Observation L4 SSS'};

vari_control_all = NaN([length(mm_all), size(mask)]);
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
    filename_control = dir(filepattern_control);
    file_control = [filepath_control, filename_control.name];
    
    try
        vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    catch
        vari_control = NaN;
    end
    if isice == 1
        try
            aice_mask = ncread(file_control,'aice')';
            aice_mask(aice_mask >= aice_value) = NaN;
            aice_mask(aice_mask <  aice_value) = 1;
            mask_with_ice = mask.*aice_mask;

            vari_control_all(mi,:,:) = vari_control.*mask_with_ice;
        catch
            vari_control_all(mi,:,:) = vari_control.*mask;
        end
    else
        vari_control_all(mi,:,:) = vari_control.*mask;
    end % isice
end
mean_model = squeeze(mean(vari_control_all,1));
std_model = squeeze(std(vari_control_all,1));
clearvars 'vari_control_all'


% Satellite
mean_sat_all = NaN([num_sat, size(mask)]);
std_sat_all = NaN([num_sat, size(mask)]);
for si = 1:num_sat

    vari_sat_interp_all = NaN([length(mm_all), size(mask)]);
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        filepath_sat = filepaths_sat{si};
        filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
        filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

        filename_sat = dir(filepattern1_sat);
        if isempty(filename_sat)
            filename_sat = dir(filepattern2_sat);
        end

        if isempty(filename_sat)
            vari_sat_interp = NaN;
        else
            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
            if si == 4
                index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
            end
            lon_sat = lon_sat - lons_360ind(si);

            if isice == 1 && si == 5
                aice_mask_sat = ncread(file_sat, 'sea_ice_fraction')';

                aice_mask_sat(aice_mask_sat >= aice_value) = NaN;
                aice_mask_sat(aice_mask_sat <  aice_value) = 1;

                vari_sat = vari_sat.*aice_mask_sat;
            end

            index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
            index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

            vari_sat_part = vari_sat(index_lat,index_lon);

            [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

            vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
            %mask_sat = ~isnan(vari_sat_interp);
            %mask_sat_model = (mask_sat./mask_sat).*mask;
            %area_sat = area.*mask_sat_model;
        end
        vari_sat_interp_all(mi,:,:) = vari_sat_interp;

    end % mi
    mean_sat_all(si,:,:) = squeeze(mean(vari_sat_interp_all,1));
    std_sat_all(si,:,:) = squeeze(std(vari_sat_interp_all,1));
    
    disp([num2str(si), ' / ', num2str(num_sat)])
end % si

% Figure mean
h1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 750])
t = tiledlayout(2,3);

% title
ttitle = annotation('textbox', [.44 .85 .15 .15], 'String', [ystr, ' Annual mean']);
ttitle.FontSize = 15;
ttitle.EdgeColor = 'None';

nexttile(1)
plot_map('Bering', 'mercator', 'l')
hold on;
pcolorm(lat,lon,mean_model.*mask);
caxis(climit)
title('ROMS Dsm_1rnoff', 'Interpreter', 'None')

for si = 1:num_sat

    % tile
    nexttile(si+1);
    plot_map('Bering', 'mercator', 'l')
    hold on;
    T(si+1) = pcolorm(lat,lon,squeeze(mean_sat_all(si,:,:)));
    caxis(climit)
    if si == num_sat
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Label.String = unit;
    end
    title(titles_sat{si}, 'Interpreter', 'None')
end

set(gcf, 'Position', [1 200 1500 750])
pause(1)
set(gcf, 'Position', [1 200 1500 750])
pause(1)
print(strcat('compare_annual_mean_', vari_str, '_satellite_', ystr),'-dpng');

% Figure std
h1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 750])
t = tiledlayout(2,3);

% title
ttitle = annotation('textbox', [.44 .85 .15 .15], 'String', [ystr, ' Annual std']);
ttitle.FontSize = 15;
ttitle.EdgeColor = 'None';

nexttile(1)
plot_map('Bering', 'mercator', 'l')
hold on;
pcolorm(lat,lon,std_model.*mask);
caxis(climit_std)
title('ROMS Dsm_1rnoff', 'Interpreter', 'None')

for si = 1:num_sat

    % tile
    nexttile(si+1);
    plot_map('Bering', 'mercator', 'l')
    hold on;
    T(si+1) = pcolorm(lat,lon,squeeze(std_sat_all(si,:,:)));
    caxis(climit_std)
    if si == num_sat
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Label.String = unit;
    end
    title(titles_sat{si}, 'Interpreter', 'None')
end

set(gcf, 'Position', [1 200 1500 750])
pause(1)
set(gcf, 'Position', [1 200 1500 750])
pause(1)
print(strcat('compare_annual_std_', vari_str, '_satellite_', ystr),'-dpng');
