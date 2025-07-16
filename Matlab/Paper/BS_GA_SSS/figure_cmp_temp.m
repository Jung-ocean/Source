clear; clc; close all

exp = 'Dsm4';
yyyy_all = [2019 2021 2022];

map = 'Trawl';

% Figure properties
interval = 2;
climit = [-2 12];
num_color = diff(climit)/interval;
contour_interval = climit(1):interval:climit(end);
color = jet(num_color);
unit = '^oC';

climit2 = [-5 5];
interval2 = 1;
[color2, contour_interval2] = get_color('redblue', climit2, interval2);

lfs = 13;
tfs = 18;

% Model
model_filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];
g = grd('BSf');
statrdate = datenum(2018,7,1);

% SST
% Observation
obs_filepath = '/data/jungjih/Observations/Bottom_trawl_survey/';
obs_filename = 'ebs_nbs_temperature_full_area.csv';
obs_file = [obs_filepath obs_filename];
obs = readtable(obs_file);

obs_bt_all = table2array(obs(:,1));
obs_st_all = table2array(obs(:,2));
obs_lat_all = table2array(obs(:,11));
obs_lon_all = table2array(obs(:,12));
obs_year_all = table2array(obs(:,13));
obs_timenum_all = datenum(table2array(obs(:,4)));

f1 = figure;
set(gcf, 'Position', [1 1 1500 900])

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Observation
    index = find(obs_year_all == yyyy);
    timenum = obs_timenum_all(index);
    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    if isempty(index)
        obsplotind = 0;
        obs_st2 = NaN;
        obs_lat2 = NaN;
        obs_lon2 = NaN;
    else
        obsplotind = 1;
        obs_st = obs_st_all(index);
        obs_lat = obs_lat_all(index);
        obs_lon = obs_lon_all(index);

        obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
        obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

        [obs_lon2, obs_lat2] = meshgrid(obs_lon_interp, obs_lat_interp);
        obs_st2 = griddata(obs_lon, obs_lat, obs_st, obs_lon2, obs_lat2);
    end

    k = boundary(obs_lon,obs_lat,1);
    [in, on] = inpolygon(obs_lon2, obs_lat2, obs_lon(k), obs_lat(k));
    mask = in./in;

    % Model
    model_st = [];
    model_lon = [];
    model_lat = [];

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/vs_bottom_trawl/csv/SST_ROMS_trawl_', ystr, '.mat']);

    % Trawl survey plot
    ax1 = subplot('Position',[.03+.15*(yi-1), .7,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf(ax1, obs_lat2, obs_lon2, obs_st2.*mask, color, climit, contour_interval);
    title('Obs SST', 'FontSize', tfs)

    textm(56.3, -179.8, [ystr], 'FontSize', 15)
    if yyyy == 2021
        textm(54.7, -179.8, ['05/30', '-', '08/17'], 'FontSize', 13.5)
    elseif yyyy == 2022
        textm(54.7, -179.8, ['05/29', '-', '08/20'], 'FontSize', 13.5)
    else
        textm(54.7, -179.8, [datestr(min(timenum_unique), 'mm/dd'), '-', datestr(max(timenum_unique), 'mm/dd')], 'FontSize', 13.5)
    end
    
    % ROMS plot
    ax2 = subplot('Position',[.03+.15*(yi-1),.4,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax2, model_lat2, model_lon2, model_st2.*mask, color, climit, contour_interval);

    title('ROMS SST', 'FontSize', tfs)

    % Difference
    ax3 = subplot('Position',[.03+.15*(yi-1),.1,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel('FontSize', 10);
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax3, model_lat2, model_lon2, model_st2.*mask - obs_st2.*mask, color2, climit2, contour_interval2);

    title('Difference', 'FontSize', tfs)
end

% Bottom temperature
% Observation
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Observation
    index = find(obs_year_all == yyyy);
    timenum = obs_timenum_all(index);
    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    if isempty(index)
        obsplotind = 0;
        obs_bt2 = NaN;
        obs_lat2 = NaN;
        obs_lon2 = NaN;
    else
        obsplotind = 1;
        obs_bt = obs_bt_all(index);
        obs_lat = obs_lat_all(index);
        obs_lon = obs_lon_all(index);

        obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
        obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

        [obs_lon2, obs_lat2] = meshgrid(obs_lon_interp, obs_lat_interp);
        obs_bt2 = griddata(obs_lon, obs_lat, obs_bt, obs_lon2, obs_lat2);
    end

    k = boundary(obs_lon,obs_lat,1);
    [in, on] = inpolygon(obs_lon2, obs_lat2, obs_lon(k), obs_lat(k));
    mask = in./in;

    % Model
    model_bt = [];
    model_lon = [];
    model_lat = [];

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/vs_bottom_trawl/csv/bottomT_ROMS_trawl_', ystr, '.mat']);

    % Trawl survey plot
    ax1 = subplot('Position',[.51+.15*(yi-1) ,.7,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off

    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf(ax1, obs_lat2, obs_lon2, obs_bt2.*mask, color, climit, contour_interval);
    [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_bt2.*mask, [2 2], '-k', 'LineWidth', 2);

    title('Obs bottom T', 'FontSize', tfs)

    textm(56.3, -179.8, [ystr], 'FontSize', 15)
    if yyyy == 2021
        textm(54.7, -179.8, ['05/30', '-', '08/17'], 'FontSize', 13.5)
    elseif yyyy == 2022
        textm(54.7, -179.8, ['05/29', '-', '08/20'], 'FontSize', 13.5)
    else
        textm(54.7, -179.8, [datestr(min(timenum_unique), 'mm/dd'), '-', datestr(max(timenum_unique), 'mm/dd')], 'FontSize', 13.5)
    end

    % ROMS plot
    ax2 = subplot('Position',[.51+.15*(yi-1) ,.4,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax2, model_lat2, model_lon2, model_bt2.*mask, color, climit, contour_interval);
    [cs2, h2] = contourm(model_lat2, model_lon2, model_bt2.*mask, [2 2], '-k', 'LineWidth', 2);

    title('ROMS bottom T', 'FontSize', tfs)

    if yi == 3
        c = colorbar('Position', [.96 .4 .01 .55]);
        c.Title.String = unit;
        c.FontSize = 12;
    end

    % Difference
    ax3 = subplot('Position',[.51+.15*(yi-1),.1,.15,.25]);
    plot_map(map, 'mercator', 'l');
    plabel('FontSize', lfs);
    mlabel('FontSize', lfs);
    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel('FontSize', 10);
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf(ax3, model_lat2, model_lon2, model_bt2.*mask - obs_bt2.*mask, color2, climit2, contour_interval2);

    title('Difference', 'FontSize', tfs)

    if yi == 3
        c = colorbar('Position', [.96 .1 .01 .25]);
        c.Title.String = unit;
        c.FontSize = 12;
        c.Ticks = contour_interval2;
    end

end
ddd
% set(gcf, 'Position', [1 1 1700 900])

exportgraphics(gcf,'figure_cmp_temp.png','Resolution',150)