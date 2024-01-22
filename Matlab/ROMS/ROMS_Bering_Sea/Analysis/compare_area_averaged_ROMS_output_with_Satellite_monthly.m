%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare two ROMS outputs through area-averaged with Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy_all = 2018:2020;
mm_all = 1:12;
depth_shelf = 200; % m
layer = 45;
num_sat = 5;

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 34.5];
        ylimit_basin = [32.2 34.0];
        climit = [31.5 33.5];
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
mask_Bering_Sea_struct = load('mask_Bering_Sea.mat', 'mask_Bering_Sea');
mask_Bering_Sea = mask_Bering_Sea_struct.mask_Bering_Sea;
h = g.h;
dx = 1./g.pm; dy = 1./g.pn;
area = dx.*dy.*mask.*mask_Bering_Sea;

index_shelf = find(h < depth_shelf);
index_basin = find(h > depth_shelf);

timenum_all = zeros(length(yyyy_all)*length(mm_all),1);
vari_control_shelf = zeros(length(yyyy_all)*length(mm_all),1);
vari_control_basin = zeros(length(yyyy_all)*length(mm_all),1);
vari_sat_shelf = zeros(num_sat, length(yyyy_all)*length(mm_all));
vari_sat_basin = zeros(num_sat, length(yyyy_all)*length(mm_all));
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

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

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');
    
    % Figure
    if yi == 1 && mi == 1
        h1 = figure; hold on;
        set(gcf, 'Position', [1 200 1500 750])
        t = tiledlayout(2,3);
    else
        delete(ttitle);
    end

    filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
    filename_control = dir(filepattern_control);
    if ~isempty(filename_control)
    file_control = [filepath_control, filename_control.name];

    vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    vari_control_shelf(12*(yi-1) + mi) = sum(vari_control(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
    vari_control_basin(12*(yi-1) + mi) = sum(vari_control(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');
    else
        vari_control = NaN;
        vari_control_shelf(12*(yi-1) + mi) = NaN;
        vari_control_basin(12*(yi-1) + mi) = NaN;
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
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T(1));
    end
    T(1) = pcolorm(lat,lon,vari_control.*mask);
    caxis(climit)
    title('ROMS Dsm_1rnoff', 'Interpreter', 'None')

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
    if si == 4
        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];
    end
    lon_sat = lon_sat - lons_360ind(si);

    index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
    index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

    vari_sat_part = vari_sat(index_lat,index_lon);

    [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

    vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
    mask_sat = ~isnan(vari_sat_interp);
    mask_sat_model = (mask_sat./mask_sat).*mask;
    area_sat = area.*mask_sat_model;
    vari_sat_shelf(si,12*(yi-1) + mi) = sum(vari_sat_interp(index_shelf).*area_sat(index_shelf), 'omitnan')./sum(area_sat(index_shelf), 'omitnan');
    vari_sat_basin(si,12*(yi-1) + mi) = sum(vari_sat_interp(index_basin).*area_sat(index_basin), 'omitnan')./sum(area_sat(index_basin), 'omitnan');
    end

    % Tile
    nexttile(si+1);

    if yi == 1 && mi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T(si+1));
    end
    T(si+1) = pcolorm(lat,lon,vari_sat_interp.*mask_sat_model);
    caxis(climit)
    if yi == 1 && mi == 1 && si == num_sat
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Label.String = unit;
    end

    title(titles_sat{si}, 'Interpreter', 'None')

    pause(1)
    %print(strcat('Compare_surface_', vari_str, '_' , time_filename),'-dpng');
    end

    % Make gif
    gifname = ['compare_surface_', vari_str, '_satellite_monthly.gif'];

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

% Plot
h1 = figure; hold on; grid on;
%set(gcf, 'Position', [1 1 1500 400])
set(gcf, 'Position', [1 1 1900 500])
t = tiledlayout(1,2);

%ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', ['Area-averaged ', vari_str]);
%ttitle.FontSize = 25;
%ttitle.EdgeColor = 'None';

% Tile 1
nexttile(1); hold on; grid on
T1p1 = plot(timenum_all, vari_control_shelf, '-ok', 'LineWidth', 2);
for si = 1:num_sat
    T1ps(si) = plot(timenum_all, vari_sat_shelf(si,:), '-o', 'LineWidth', 2);
end
xticks(timenum_all);
datetick('x', 'mmm, yyyy', 'keepticks')
ylim(ylimit_shelf);
ylabel(unit)
title(['Shelf area averaged (< ', num2str(depth_shelf), ' m)'])
l = legend([T1p1, T1ps], [case_control, titles_sat], 'Interpreter', 'none');
l.NumColumns = 2; 
l.Location = 'Northwest';
%l.FontSize = 15;

% Tile 2
nexttile(2); hold on; grid on
T2p1 = plot(timenum_all, vari_control_basin, '-ok', 'LineWidth', 2);
for si = 1:num_sat
    T2ps(si) = plot(timenum_all, vari_sat_basin(si,:), '-o', 'LineWidth', 2);
end
xticks(timenum_all);
datetick('x', 'mmm, yyyy', 'keepticks')
ylim(ylimit_basin);
ylabel(unit)
title(['Basin area averaged (> ', num2str(depth_shelf), ' m)'])
%l = legend([T2p1, T2p2, T2ps], [case_control, case_exp, titles_sat], 'Interpreter', 'none');
%l.Location = 'SouthWest';
%l.FontSize = 15;

pause(1)
print(strcat('compare_area_averaged_', vari_str, '_with_Satellite_monthly'),'-dpng');