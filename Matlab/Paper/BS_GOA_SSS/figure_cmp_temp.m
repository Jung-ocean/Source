clear; clc; close all

exp = 'Dsm4';
yyyy_all = [2019 2021 2022];

% Figure properties
interval = 2;
climit = [-2 12];
num_color = diff(climit)/interval;
contour_interval = climit(1):interval:climit(end);
color = jet(num_color);
unit = '^oC';

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

    % Model
    model_st = [];
    model_lon = [];
    model_lat = [];

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/vs_bottom_trawl/csv/SST_ROMS_trawl_', ystr, '.mat']);

    % Trawl survey plot
    subplot('Position',[.05,.7 - .3*(yi-1),.15,.25])
    plot_map('Eastern_Bering', 'mercator', 'l');
    if yi ~= 3
        mlabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf([], obs_lat2, obs_lon2, obs_st2, color, climit, contour_interval);
    if yi == 1
        title('Trawl survey SST', 'FontSize', 12)
    end

    textm(53.5, -184, [ystr], 'FontSize', 20)
    textm(50.5, -184, ['(', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 15)

    % ROMS plot
    subplot('Position',[.20,.7 - .3*(yi-1),.15,.25])
    plot_map('Eastern_Bering', 'mercator', 'l');
    plabel off
    if yi ~= 3
        mlabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf([], model_lat2, model_lon2, model_st2, color, climit, contour_interval);
%     c = colorbar;
%     c.Title.String = '^oC';

    if yi == 1
        title('ROMS SST', 'FontSize', 12)
    end

    textm(53.5, -184, [ystr], 'FontSize', 20)
    textm(50.5, -184, ['(', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 15)

%     title(t, [ystr, ' (', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 25)
%     print(['cmp_SST_w_trawl_', ystr], '-dpng')
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

    % Model
    model_bt = [];
    model_lon = [];
    model_lat = [];

    load(['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/vs_bottom_trawl/csv/bottomT_ROMS_trawl_', ystr, '.mat']);
    
    % Trawl survey plot
    subplot('Position',[.40,.7 - .3*(yi-1),.15,.25])
    plot_map('Eastern_Bering', 'mercator', 'l');
    if yi ~= 3
        mlabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf([], obs_lat2, obs_lon2, obs_bt2, color, climit, contour_interval);
    [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_bt2, [2 2], '-k', 'LineWidth', 2);

    if yi == 1
        title('Trawl survey bottom T', 'FontSize', 12)
    end

    textm(53.5, -184, [ystr], 'FontSize', 20)
    textm(50.5, -184, ['(', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 15)

    % ROMS plot
    subplot('Position',[.55,.7 - .3*(yi-1),.15,.25])
    plot_map('Eastern_Bering', 'mercator', 'l');
    plabel off
    if yi ~= 3
        mlabel off
    end
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pmodel = plot_contourf([], model_lat2, model_lon2, model_bt2, color, climit, contour_interval);
    [cs2, h2] = contourm(model_lat2, model_lon2, model_bt2, [2 2], '-k', 'LineWidth', 2);

    if yi == 1
        title('ROMS bottom T', 'FontSize', 12)
    end

    textm(53.5, -184, [ystr], 'FontSize', 20)
    textm(50.5, -184, ['(', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 15)

end

c = colorbar('Position', [.70 .1 .01 .85]);
c.Title.String = '^oC';
c.FontSize = 12;
fff
exportgraphics(gcf,'figure_cmp_temp.png','Resolution',150) 