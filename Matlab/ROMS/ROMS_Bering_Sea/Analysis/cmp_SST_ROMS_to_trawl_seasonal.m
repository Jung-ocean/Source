%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SST to bottom trawl survey temperature
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
yyyy_all = [2019 2021 2022 2023];
% yyyy_all = [2019];

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

    if exist(['SST_ROMS_trawl_', ystr, '.mat']) ~= 0
        load(['SST_ROMS_trawl_', ystr, '.mat']);
    else

    for ti = 1:length(timenum_unique)
        timenum_tmp = timenum_unique(ti);

        dindex = find(timenum_floor == timenum_tmp);
        filenumber = timenum_tmp - statrdate + 1;
        fstr = num2str(filenumber, '%04i');
        model_filename = [exp, '_avg_', fstr, '.nc'];
        model_file = [model_filepath, model_filename];
        if filenumber == 1826
            model_file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
        end
        temp = ncread(model_file, 'temp');
        SST = squeeze(temp(:,:,g.N));
        
        for di = 1:length(dindex)

            lon_tmp = obs_lon(dindex(di));
            lat_tmp = obs_lat(dindex(di));

            dist = sqrt((g.lon_rho - lon_tmp).^2 + abs(g.lat_rho - lat_tmp).^2);
            [lonind, latind] = find(dist == min(dist(:)));

            model_st = [model_st; SST(lonind, latind)];
            model_lon = [model_lon; g.lon_rho(lonind, latind)];
            model_lat = [model_lat; g.lat_rho(lonind, latind)];
        end % di

        disp([num2str(ti), ' / ', num2str(length(timenum_unique)), ' ...'])
    end % ti

    model_lat_interp = min(model_lat):0.05:max(model_lat);
    model_lon_interp = min(model_lon):0.05:max(model_lon);

    [model_lon2, model_lat2] = meshgrid(model_lon_interp, model_lat_interp);
    model_st2 = griddata(model_lon, model_lat, model_st, model_lon2, model_lat2);

    save(['SST_ROMS_trawl_', ystr, '.mat'], 'model_lon2', 'model_lat2', 'model_st2');
    end % exist

    % Plot
    f1 = figure;
    set(gcf, 'Position', [1 200 1200 650])
    t = tiledlayout(1,2);

    nexttile(1)
    plot_map('Eastern_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

%     pobs = pcolorm(obs_lat2, obs_lon2, obs_st2);
%     colormap jet;
%     uistack(pobs,'bottom')
%     caxis(climit)
    pobs = plot_contourf(obs_lat2, obs_lon2, obs_st2, contour_interval, climit, color);


%     if obsplotind == 1
%         [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_st2, [2 2], '-k', 'LineWidth', 4);
%     end
%     l = legend(h2, '2 ^oC isotherm');
%     l.Location = 'NorthWest';
%     l.FontSize = 15;
    title('Trawl survey SST', 'FontSize', 15)

    nexttile(2)
    plot_map('Eastern_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

%     pmodel = pcolorm(model_lat2, model_lon2, model_st2);
%     colormap jet;
%     uistack(pmodel,'bottom')
%     caxis(climit)
    pmodel = plot_contourf(model_lat2, model_lon2, model_st2, contour_interval, climit, color);

    c = colorbar;
    c.Title.String = '^oC';
%     [cs2, h2] = contourm(model_lat2, model_lon2, model_st2, [2 2], '-k', 'LineWidth', 4);
    title('ROMS SST', 'FontSize', 15)

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, [ystr, ' (', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 25)

    print(['cmp_SST_w_trawl_', ystr], '-dpng')
end