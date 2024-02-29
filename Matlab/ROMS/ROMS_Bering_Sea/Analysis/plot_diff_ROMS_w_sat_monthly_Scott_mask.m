%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot difference between two ROMS outputs through with Satellite
% by applying Scott's mask
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Eastern_Bering';

vari_str = 'salt';

%yyyymm_all = {'201811', '201906'};
yyyymm_all = {'201910', '202006'};
layer = 45;
num_sat = 5;

region = 'eshelf';
mask_Scott = load('/data/sdurski/ROMS_Setups/Initial/Bering_Sea/BSf_region_polygons.mat');
indmask = eval(['mask_Scott.ind', region]);
[row,col] = ind2sub([1460, 957], indmask);
indmask = sub2ind([957, 1460], col, row); % transpose

isice = 1;
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
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;

mask = g.mask_rho./g.mask_rho;
area = dx.*dy.*mask;

mask_ind = NaN(size(mask));
mask_ind(indmask) = 1;
mask = mask.*mask_ind;
area = area.*mask_ind;

for ymi = 1:2
    yyyymm = yyyymm_all{ymi};
    yyyy = str2num(yyyymm(1:4)); ystr = num2str(yyyy);
    mm = str2num(yyyymm(5:6)); mstr = num2str(mm, '%02i');

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/', ystr, '/'];
    filepath_RSS_40 = filepath_RSS_70;
    % JPL SMAP v5.0 (https://podaac.jpl.nasa.gov/dataset/SMAP_JPL_L3_SSS_CAP_8DAY-RUNNINGMEAN_V5)
    %filepath_JPL = ['/data/jungjih/Observations/Satellite_SSS/BS/JPL/monthly/'];
    % CEC SMOS v8.0
    filepath_CEC = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/monthly/'];
    % OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
    filepath_OISSS = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];
    % CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/', ystr, '/'];
    filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_CEC, filepath_OISSS, filepath_CMEMS};

    lons_sat = {'lon', 'lon', 'lon', 'longitude', 'lon'};
    lons_360ind = [360, 360, 180, 180, 360];
    lats_sat = {'lat', 'lat', 'lat', 'latitude', 'lat'};
    varis_sat = {'sss_smap', 'sss_smap_40km', 'SSS', 'sss', 'sos'};
    titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)', 'RSS SMAP L3 SSS v5.3 8-day MA (40 km)', 'CEC SMOS L3 SSS v8.0 9-day MA', 'OISSS L4 v2.0 7-day decorr time scale', 'CMEMS Multi Observation L4 SSS'};

    filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
    filename_control = dir(filepattern_control);
    if ~isempty(filename_control)
        file_control = [filepath_control, filename_control.name];

        vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
        if isice == 1
            try
                aice_mask = ncread(file_control,'aice')';
                aice_mask(aice_mask >= aice_value) = NaN;
                aice_mask(aice_mask < aice_value) = 1;
                mask_with_ice = mask.*aice_mask;
                area_with_ice = area.*aice_mask;

            catch
            end
        else
        end % isice

    else
    end

    if isice == 1
        try
            vari_control_all(ymi,:,:) = vari_control.*mask_with_ice;
        catch
            vari_control_all(ymi,:,:) = vari_control.*mask;
        end
    else
        vari_control_all(ymi,:,:) = vari_control.*mask;
    end % isice

    % Satellite
    for si = 1:num_sat
        filepath_sat = filepaths_sat{si};
        filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
        filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

        filename_sat = dir(filepattern1_sat);
        if isempty(filename_sat)
            filename_sat = dir(filepattern2_sat);
        end

        if isempty(filename_sat)
            vari_sat_shelf(si,12*(yi-1) + mi) = NaN;
            vari_sat_basin(si,12*(yi-1) + mi) = NaN;
            vari_sat_interp = NaN;
        else
            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
            %if si == 4
            if si == 3 || si == 4
                index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
            end
            lon_sat = lon_sat - lons_360ind(si);

            if isice == 1 && si == 5
                aice_mask_sat = ncread(file_sat, 'sea_ice_fraction')';

                aice_mask_sat(aice_mask_sat >= aice_value) = NaN;
                aice_mask_sat(aice_mask_sat < aice_value) = 1;

                vari_sat = vari_sat.*aice_mask_sat;
            end

            index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
            index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

            vari_sat_part = vari_sat(index_lat,index_lon);

            [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

            vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
            mask_sat = ~isnan(vari_sat_interp);
            mask_sat_model = (mask_sat./mask_sat).*mask;
        end

        vari_sat_all(si,ymi,:,:) = vari_sat_interp.*mask_sat_model;

    end % si
    disp([ystr, mstr, '...'])
end % ymi

vari_control_diff = squeeze(vari_control_all(2,:,:) - vari_control_all(1,:,:));
vari_sat_diff = squeeze(diff(vari_sat_all, [], 2));

% Figure
h1 = figure; hold on;
%set(gcf, 'Position', [1 200 1500 750])
set(gcf, 'Position', [1 200 1400 900])
t = tiledlayout(2,3);

% Figure title
title_str1 = datestr(datenum(yyyymm_all{1},'yyyymm'), 'mmm yyyy');
title_str2 = datestr(datenum(yyyymm_all{2},'yyyymm'), 'mmm yyyy');
ttitle = annotation('textbox', [.37 .85 .35 .15], 'String', [title_str2, ' - ', title_str1]);
ttitle.FontSize = 25;
ttitle.EdgeColor = 'None';

nexttile(1)
plot_map(map, 'mercator', 'l')
hold on;
contourm(lat, lon, h, [50 200], 'k');

T(1) = pcolorm(lat,lon,vari_control_diff);
uistack(T(1),'bottom')
colormap('redblue')
caxis(climit)
title('ROMS Dsm_1rnoff', 'Interpreter', 'None')

% Satellite
for si = 1:num_sat
    % Tile
    nexttile(si+1);

    plot_map(map, 'mercator', 'l')
    hold on;
    contourm(lat, lon, h, [50 200], 'k');

    T(si+1) = pcolorm(lat,lon,squeeze(vari_sat_diff(si,:,:)));
    uistack(T(si+1),'bottom')
    colormap('redblue')
    caxis(climit)
    if si == num_sat
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Label.String = unit;
    end

    title(titles_sat{si}, 'Interpreter', 'None')
end

pause(1)
print(strcat('diff_surface_', vari_str, '_monthly_', region, '_', title_str2, '_', title_str1),'-dpng');