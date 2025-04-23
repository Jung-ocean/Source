%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare N to bottom trawl survey value
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'mean_N';
yyyy_all = [2021 2022 2023];

exp = 'Dsm4';
g = grd('BSf');
statrdate = datenum(2018,7,1);

% Figure properties
if strcmp(vari_str, 'max_N')
    title_str = 'maximum N';
    scale = 1e3;
    interval = 0.3;
    climit = [0 3];
    num_color = double(diff(climit)/interval);
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = ['x 10^-^', num2str(log10(scale)), ' s^-^1'];

elseif strcmp(vari_str, 'mean_N')
    title_str = 'depth-averaged N';
    scale = 1e2;
    climit = [0 1.2];
    [color, contour_interval] = get_color('jet', climit, .1);
    unit = ['x 10^-^', num2str(log10(scale)), ' s^-^1'];

elseif strcmp(vari_str, 'max_depth')
    title_str = 'depth of maximum N';
    scale = 1;
    interval = 5;
    climit = [0 50];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = 'm';
end

% Model
model_filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Observation
obs_filepath = '/data/jungjih/Observations/Bottom_trawl_survey/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    obs_filename = ['GAPCTD_', ystr, '_EBS.nc'];
    obs_file = [obs_filepath obs_filename];

    obs_lat_all = ncread(obs_file, 'latitude');
    obs_lon_all = ncread(obs_file, 'longitude');

    obs_depth = ncread(obs_file, 'depth');
    obs_N2 = ncread(obs_file, 'buoyancy_frequency');
    obs_N2(obs_N2 < 0) = 0;
    obs_N = sqrt(obs_N2);
    obs_density = ncread(obs_file, 'sea_water_density');

    obs_time = ncread(obs_file, 'time');
    obs_timenum = datenum(obs_time);

    obs_max_N = [];
    obs_max_depth = [];
    obs_mean_N = [];
    % Observation
    timenum = obs_timenum;

    for li = 1:size(obs_N, 2)
        obs_vari_tmp = obs_N(:,li);
        index = find(obs_vari_tmp == max(obs_vari_tmp));
        if length(index) > 1
            index = index(1);
        end
        obs_max_N(:,li) = obs_vari_tmp(index);
        obs_max_depth(:,li) = obs_depth(index);
        obs_mean_N(:,li) = mean(obs_vari_tmp, 'omitnan');
    end

    obs_max_N = double(obs_max_N);
    obs_max_depth = double(obs_max_depth);
    obs_mean_N = double(obs_mean_N);
    obs_lat = double(obs_lat_all);
    obs_lon = double(obs_lon_all);

    if yyyy == 2021
        index = find(timenum > datenum(2021,8,1) & obs_lat < 60);
        timenum(index) = [];
        obs_lat(index) = [];
        obs_lon(index) = [];
        obs_max_N(index) = [];
        obs_max_depth(index) = [];
        obs_mean_N(index) = [];
    end

    timenum_floor = floor(timenum);
    timenum_unique = unique(floor(timenum));

    obs_lat_interp = min(obs_lat):0.05:max(obs_lat);
    obs_lon_interp = min(obs_lon):0.05:max(obs_lon);

    [obs_lon2, obs_lat2] = meshgrid(obs_lon_interp, obs_lat_interp);
    obs_max_N_2d = griddata(obs_lon, obs_lat, obs_max_N, obs_lon2, obs_lat2);
    obs_max_depth_2d = griddata(obs_lon, obs_lat, obs_max_depth, obs_lon2, obs_lat2);
    obs_mean_N_2d = griddata(obs_lon, obs_lat, obs_mean_N, obs_lon2, obs_lat2);

    % Model
    model_max_N = [];
    model_max_depth = [];
    model_mean_N = [];
    model_lon = [];
    model_lat = [];

    if exist(['N_ROMS_trawl_', ystr, '.mat']) ~= 0
        load(['N_ROMS_trawl_', ystr, '.mat']);
    else
        for ti = 1:length(timenum_unique)
            timenum_tmp = timenum_unique(ti);
            dindex = find(timenum_floor == timenum_tmp);

            for di = 1:length(dindex)

                lon_tmp = obs_lon(dindex(di));
                lat_tmp = obs_lat(dindex(di));

                profile = load_BSf_profile(g, timenum_tmp, lat_tmp, lon_tmp);
                depth_tmp = -profile.depth;
                N2 = profile.N2;
                N2(N2<0) = 0;
                N_tmp = sqrt(N2);
                dz_tmp = abs(depth_tmp(2:end) - depth_tmp(1:end-1));
                
                mean_N_tmp = sum((N_tmp.*dz_tmp))./sum(dz_tmp);

                index = find(N_tmp == max(N_tmp));
                if length(index) > 1
                    index = index(1);
                end
                model_max_N = [model_max_N; N_tmp(index)];
                model_max_depth = [model_max_depth; depth_tmp(index)];
                model_mean_N = [model_mean_N; mean_N_tmp];

                model_lon = [model_lon; profile.lon];
                model_lat = [model_lat; profile.lat];
            end % di

            disp([num2str(ti), ' / ', num2str(length(timenum_unique)), ' ...'])
        end % ti

        model_lon2 = obs_lon2;
        model_lat2 = obs_lat2;
        model_max_N_2d = griddata(model_lon, model_lat, model_max_N, model_lon2, model_lat2);
        model_max_depth_2d = griddata(model_lon, model_lat, model_max_depth, model_lon2, model_lat2);
        model_mean_N_2d = griddata(model_lon, model_lat, model_mean_N, model_lon2, model_lat2);

        save(['N_ROMS_trawl_', ystr, '.mat'], 'model_lon2', 'model_lat2', 'model_max_N_2d', 'model_max_depth_2d', 'model_mean_N_2d');
    end % exist
    
    obs_vari2 = eval(['obs_', vari_str, '_2d']);
    model_vari2 = eval(['model_', vari_str, '_2d']);

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
    pobs = plot_contourf(obs_lat2, obs_lon2, obs_vari2.*scale, contour_interval, climit, color);

    %     if obsplotind == 1
    %         [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_st2, [2 2], '-k', 'LineWidth', 4);
    %     end
    %     l = legend(h2, '2 ^oC isotherm');
    %     l.Location = 'NorthWest';
    %     l.FontSize = 15;
    title(['Trawl survey ', title_str], 'FontSize', 15)

    nexttile(2)
    plot_map('Eastern_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    %     pmodel = pcolorm(model_lat2, model_lon2, model_st2);
    %     colormap jet;
    %     uistack(pmodel,'bottom')
    %     caxis(climit)
    pmodel = plot_contourf(model_lat2, model_lon2, model_vari2.*scale, contour_interval, climit, color);

    c = colorbar;
    c.Title.String = unit;
    title(['ROMS ', title_str], 'FontSize', 15)

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, [ystr, ' (', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 25)

    print(['cmp_', vari_str, '_w_trawl_', ystr], '-dpng')
end