%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare two ROMS outputs through area-averaged with Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy = 2018; ystr = num2str(yyyy);
filenum_all = 1:152;
depth_target = 200; % m
layer = 45;

switch vari_str
    case 'salt'
        ylimit_shelf = [30.5 33.5];
        ylimit_basin = [32 33.7];
        climit = [31.5 33.5];
        unit = 'g/kg';
    case 'temp'
        climit = [0 20];
        unit = '^oC';
end

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_', ystr, '/'];
case_control = 'Dsm_1';
filepath_control = [filepath_all, case_control, '/'];

case_exp = 'Dsm_1rnoff';
filepath_exp = [filepath_all, case_exp, '/'];

% Satellite SSS
num_sat = 5;
% RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/8day_running/', ystr, '/'];
filepath_RSS_40 = filepath_RSS_70;
% JPL SMAP v5.0 (https://podaac.jpl.nasa.gov/dataset/SMAP_JPL_L3_SSS_CAP_8DAY-RUNNINGMEAN_V5)
filepath_JPL = ['/data/sdurski/Observations/Satellite_SSS/BS/JPL/', ystr, '/'];
% OISSS L4 v2.0 (https://podaac.jpl.nasa.gov/dataset/OISSS_L4_multimission_7day_v2)
filepath_OISSS = ['/data/sdurski/Observations/Satellite_SSS/OISSS_v2/'];
% CMEMS Multi Observation Global Ocean SSS (https://data.marine.copernicus.eu/product/MULTIOBS_GLO_PHY_S_SURFACE_MYNRT_015_013/description)
filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/daily/', ystr, '/'];
filepaths_sat = {filepath_RSS_70, filepath_RSS_40, filepath_JPL, filepath_OISSS, filepath_CMEMS};

lons_sat = {'lon', 'lon', 'longitude', 'longitude', 'lon'};
lons_360ind = [360, 360, 0, 180, 360];
lats_sat = {'lat', 'lat', 'latitude', 'latitude', 'lat'};
varis_sat = {'sss_smap', 'sss_smap_40km', 'sss', 'sss', 'sos'};
titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)', 'RSS SMAP L3 SSS v5.3 8-day MA (40 km)', 'JPL SMAP L3 SSS v5.0 8-day MA (60 km)', 'OISSS L4 v2.0 7-day decorr time scale', 'CMEMS Multi Observation L4 SSS'};

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

index_shelf = find(h < depth_target);
index_basin = find(h > depth_target);

timenum_all = zeros(length(filenum_all),1);
vari_control_shelf = zeros(length(filenum_all),1);
vari_control_basin = zeros(length(filenum_all),1);
vari_exp_shelf = zeros(length(filenum_all),1);
vari_exp_basin = zeros(length(filenum_all),1);
vari_sat_shelf = zeros(num_sat, length(filenum_all));
vari_sat_basin = zeros(num_sat, length(filenum_all));
for fi = 1:length(filenum_all)
    filenum = filenum_all(fi); fstr = num2str(filenum, '%04i');
    
    filepattern_control = fullfile(filepath_control,(['*avg*',fstr,'*.nc']));
    filename_control = dir(filepattern_control);
    file_control = [filepath_control, filename_control.name];

    vari_control = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    vari_control_shelf(fi) = sum(vari_control(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
    vari_control_basin(fi) = sum(vari_control(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');

    time = ncread(file_control, 'ocean_time');
    time_units = ncreadatt(file_control, 'ocean_time', 'units');
    time_ref = datenum(time_units(end-18:end), 'yyyy-mm-dd HH:MM:SS');
    timenum = time_ref + time/60/60/24;
    time_title = datestr(timenum, 'mmm dd, yyyy');
    timenum_all(fi) = timenum;

    filepattern_exp = fullfile(filepath_exp,(['*avg*',fstr,'*.nc']));
    filename_exp = dir(filepattern_exp);
    file_exp = [filepath_exp, filename_exp.name];

    vari_exp = ncread(file_exp,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
    vari_exp_shelf(fi) = sum(vari_exp(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
    vari_exp_basin(fi) = sum(vari_exp(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');

    % Satellite
    % Figure
    if fi == 1
        h1 = figure; hold on;
        set(gcf, 'Position', [1 1 1500 600])
        t = tiledlayout(2,3);
    else
        delete(ttitle);
    end
    ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', time_title);
    ttitle.FontSize = 25;
    ttitle.EdgeColor = 'None';

    for si = 1:num_sat
    filepath_sat = filepaths_sat{si};
    filenum_sat = ceil(timenum - datenum(yyyy,1,1)); fsstr = num2str(filenum_sat, '%03i');
    filepattern1_sat = fullfile(filepath_sat, (['*', ystr, '_', fsstr, '*.nc']));
    filepattern2_sat = fullfile(filepath_sat, (['*', ystr, datestr(timenum, 'mmdd'), '*.nc']));
    filepattern3_sat = fullfile(filepath_sat, (['*', ystr, datestr(timenum, '-mm-dd'), '*.nc']));
    
    filename_sat = dir(filepattern1_sat);
    if isempty(filename_sat)
        filename_sat = dir(filepattern2_sat);
    end
    if isempty(filename_sat)
        filename_sat = dir(filepattern3_sat);
    end
    
    if isempty(filename_sat)
        vari_sat_shelf(si,fi) = NaN;
        vari_sat_basin(si,fi) = NaN;
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
    vari_sat_shelf(si,fi) = sum(vari_sat_interp(index_shelf).*area_sat(index_shelf), 'omitnan')./sum(area_sat(index_shelf), 'omitnan');
    vari_sat_basin(si,fi) = sum(vari_sat_interp(index_basin).*area_sat(index_basin), 'omitnan')./sum(area_sat(index_basin), 'omitnan');
    end

    % Tile
    if si < 2
        nexttile(si);
    else
        nexttile(si+1);
    end
    if fi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
    else
        delete(T(si));
    end
    T(si) = pcolorm(lat,lon,vari_sat_interp.*mask_sat_model);
    caxis(climit)
    if fi == 1 && si == num_sat
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Label.String = unit;
    end

    title(titles_sat{si}, 'Interpreter', 'None')

    pause(1)
    %print(strcat('Compare_surface_', vari_str, '_' , time_filename),'-dpng');

    end

    % Make gif
    gifname = ['compare_surface_', vari_str, '_satellite.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if fi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    disp([fstr, ' / ', num2str(filenum_all(end), '%04i'), '...'])
end % fi
timevec = datevec(timenum_all);
xtic_list = datenum(unique(timevec(:,1)), unique(timevec(:,2)), 1);

% Plot
h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 1 1500 400])
t = tiledlayout(1,2);

%ttitle = annotation('textbox', [.44 .85 .1 .1], 'String', ['Area-averaged ', vari_str]);
%ttitle.FontSize = 25;
%ttitle.EdgeColor = 'None';

% Tile 1
nexttile(1); hold on; grid on
T1p1 = plot(timenum_all, vari_control_shelf, '-r', 'LineWidth', 2);
T1p2 = plot(timenum_all, vari_exp_shelf, '--b', 'LineWidth', 2);
for si = 1:num_sat
    if si == 4
        linestyle = 'o';
    else
        linestyle = '-';
    end
    T1ps(si) = plot(timenum_all, vari_sat_shelf(si,:), linestyle, 'LineWidth', 2);
end
xticks(xtic_list);
datetick('x', 'mmm dd, yyyy', 'keepticks')
xlim([timenum_all(1)-1 timenum_all(end)])
ylim(ylimit_shelf);
ylabel(unit)
title(['Shelf area averaged (< ', num2str(depth_target), ' m)'])
l = legend([T1p1, T1p2, T1ps], [case_control, case_exp, titles_sat], 'Interpreter', 'none');
l.Location = 'Northwest';
%l.FontSize = 15;

% Tile 2
nexttile(2); hold on; grid on
T2p1 = plot(timenum_all, vari_control_basin, '-r', 'LineWidth', 2);
T2p2 = plot(timenum_all, vari_exp_basin, '--b', 'LineWidth', 2);
for si = 1:num_sat
    if si == 4
        linestyle = 'o';
    else
        linestyle = '-';
    end
    T2ps(si) = plot(timenum_all, vari_sat_basin(si,:), linestyle, 'LineWidth', 2);
end
xticks(xtic_list);
datetick('x', 'mmm dd, yyyy', 'keepticks')
xlim([timenum_all(1)-1 timenum_all(end)])
ylim(ylimit_basin);
ylabel(unit)
title(['Basin area averaged (> ', num2str(depth_target), ' m)'])
%l = legend([T2p1, T2p2, T2ps], [case_control, case_exp, titles_sat], 'Interpreter', 'none');
%l.Location = 'SouthWest';
%l.FontSize = 15;

pause(1)
print(strcat('compare_area_averaged_', vari_str, '_with_Satellite'),'-dpng');