clear; clc; close all

exp = 'Dsm4';
yyyy_all = [2021 2022];

map = 'Trawl';

% Figure properties
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color('jet', climit, interval);
unit = 'psu';

climit2 = [-2 2];
interval2 = 0.5;
[color2, contour_interval2] = get_color('redblue', climit2, interval2);

lfs = 13;
tfs = 18;

filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/vs_bottom_trawl/';

% Model
model_filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
g = grd('BSf');
statrdate = datenum(2018,7,1);

% SSS
obs_filepath = '/data/jungjih/Observations/Bottom_trawl_survey/';

f1 = figure;
set(gcf, 'Position', [1 1 1500 900])
for yi = 1:length(yyyy_all)

    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Observation
    obs_filename = ['GAPCTD_', ystr, '_EBS.nc'];
    obs_file = [obs_filepath obs_filename];

    obs_lat_all = ncread(obs_file, 'latitude');
    obs_lon_all = ncread(obs_file, 'longitude');

    obs_vari = ncread(obs_file, 'sea_water_salinity', [1 1], [1 Inf]);
    obs_vari = obs_vari';
    
    obs_time = ncread(obs_file, 'time');
    obs_timenum = datenum(obs_time);

    timenum = obs_timenum;
    
    obs_vari = double(obs_vari);
    obs_lat = double(obs_lat_all);
    obs_lon = double(obs_lon_all);

    if yyyy == 2021
        index = find(timenum > datenum(2021,8,1) & obs_lat < 60);
        timenum(index) = [];
        obs_lat(index) = [];
        obs_lon(index) = [];
        obs_vari(index) = [];
    end

    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
    obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

    [obs_lon2, obs_lat2] = meshgrid(obs_lon_interp, obs_lat_interp);
    obs_vari2 = griddata(obs_lon, obs_lat, obs_vari, obs_lon2, obs_lat2);

    k = boundary(obs_lon,obs_lat,1);
    [in, on] = inpolygon(obs_lon2, obs_lat2, obs_lon(k), obs_lat(k));
    mask = in./in;

    % Model
    model_st = [];
    model_lon = [];
    model_lat = [];

    load([filepath, 'SSS_ROMS_trawl_', ystr, '.mat']);

    % Trawl survey plot
    ax1 = subplot('Position',[.05+.15*(yi-1), .7,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf(ax1, obs_lat2, obs_lon2, obs_vari2.*mask, color, climit, contour_interval);
    
    title('Obs SSS', 'FontSize', tfs)

    textm(56.3, -179.8, [ystr], 'FontSize', 15)
    textm(54.7, -179.8, [datestr(min(timenum_unique), 'mm/dd'), '-', datestr(max(timenum_unique), 'mm/dd')], 'FontSize', 13.5)

    % ROMS plot
    ax2 = subplot('Position',[.05+.15*(yi-1),.4,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax2, model_lat2, model_lon2, model_vari2.*mask, color, climit, contour_interval);

    title('ROMS SSS', 'FontSize', tfs)

    % Difference
    ax3 = subplot('Position',[.05+.15*(yi-1),.1,.15,.25]);    
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax3, model_lat2, model_lon2, model_vari2.*mask - obs_vari2.*mask, color2, climit2, contour_interval2);

    title('Difference', 'FontSize', tfs)

end

% Bottom salinity
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Observation
    obs_filename = ['GAPCTD_', ystr, '_EBS.nc'];
    obs_file = [obs_filepath obs_filename];

    obs_lat_all = ncread(obs_file, 'latitude');
    obs_lon_all = ncread(obs_file, 'longitude');

    obs_vari = ncread(obs_file, 'sea_floor_salinity');
    obs_vari = obs_vari';
    
    obs_time = ncread(obs_file, 'time');
    obs_timenum = datenum(obs_time);

    timenum = obs_timenum;
    
    obs_vari = double(obs_vari);
    obs_lat = double(obs_lat_all);
    obs_lon = double(obs_lon_all);

    if yyyy == 2021
        index = find(timenum > datenum(2021,8,1) & obs_lat < 60);
        timenum(index) = [];
        obs_lat(index) = [];
        obs_lon(index) = [];
        obs_vari(index) = [];
    end

    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
    obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

    [obs_lon2, obs_lat2] = meshgrid(obs_lon_interp, obs_lat_interp);
    obs_vari2 = griddata(obs_lon, obs_lat, obs_vari, obs_lon2, obs_lat2);

    % Model
    model_st = [];
    model_lon = [];
    model_lat = [];

    load([filepath, 'botS_ROMS_trawl_', ystr, '.mat']);

    % Trawl survey plot
    ax1 = subplot('Position',[.39+.15*(yi-1) ,.7,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf(ax1, obs_lat2, obs_lon2, obs_vari2.*mask, color, climit, contour_interval);
    title('Obs bottom S', 'FontSize', tfs)

    textm(56.3, -179.8, [ystr], 'FontSize', 15)
    textm(54.7, -179.8, [datestr(min(timenum_unique), 'mm/dd'), '-', datestr(max(timenum_unique), 'mm/dd')], 'FontSize', 13.5)

    % ROMS plot
    ax2 = subplot('Position',[.39+.15*(yi-1) ,.4,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax2, model_lat2, model_lon2, model_vari2.*mask, color, climit, contour_interval);

    title('ROMS bottom S', 'FontSize', tfs)

    if yi == 2
        c = colorbar('Position', [.70 .4 .01 .55]);
        c.Title.String = unit;
        c.FontSize = 12;
    end

    % Difference
    ax3 = subplot('Position',[.39+.15*(yi-1),.1,.15,.25]);    
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax3, model_lat2, model_lon2, model_vari2.*mask - obs_vari2.*mask, color2, climit2, contour_interval2);

    title('Difference', 'FontSize', tfs)

    if yi == 2
        c = colorbar('Position', [.70 .1 .01 .25]);
        c.Title.String = unit;
        c.FontSize = 12;
        c.Ticks = contour_interval2;
    end
end

fff
% set(gcf, 'Position', [1 1 1700 900])

exportgraphics(gcf,'figure_cmp_salt.png','Resolution',150) 