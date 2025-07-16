%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS SST to bottom trawl survey temperature
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'SST';
yyyy_all = [2019];

exp = 'Dsm4';
g = grd('BSf');
statrdate = datenum(2018,7,1);

% Figure properties
if strcmp(vari_str, 'SST') | strcmp(vari_str, 'botT')
    vari_roms = 'temp';
    interval = 2;
    climit = [-2 12];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = '^oC';

    if strcmp(vari_str(1:3), 'bot')
        vari_obs = 'sea_floor_temperature';
        layer = 1;
    else
        vari_obs = 'sea_water_temperature';
        layer = g.N;
    end
elseif strcmp(vari_str, 'SSS') | strcmp(vari_str, 'botS')
    vari_roms = 'salt';
    interval = 0.25;
    climit = [29 34];
    num_color = diff(climit)/interval;
    contour_interval = climit(1):interval:climit(end);
    color = jet(num_color);
    unit = 'psu';

    if strcmp(vari_str(1:3), 'bot')
        vari_obs = 'sea_floor_salinity';
        layer = 1;
    else
        vari_obs = 'sea_water_salinity';
        layer = g.N;
    end
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

    if strcmp(vari_str(1:3), 'bot')
        obs_vari = ncread(obs_file, vari_obs);
    else
        obs_vari = ncread(obs_file, vari_obs, [1 1], [1 Inf]);
        obs_vari = obs_vari';
    end

    obs_time = ncread(obs_file, 'time');
    obs_timenum = datenum(obs_time);

    % Observation
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
    model_vari = [];
    model_lon = [];
    model_lat = [];

    if exist([vari_str, '_ROMS_trawl_', ystr, '.mat']) ~= 0
        load([vari_str, '_ROMS_trawl_', ystr, '.mat']);
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
            vari = ncread(model_file, vari_roms);
            vari = squeeze(vari(:,:,layer));

            for di = 1:length(dindex)

                lon_tmp = obs_lon(dindex(di));
                lat_tmp = obs_lat(dindex(di));

                dist = sqrt((g.lon_rho - lon_tmp).^2 + abs(g.lat_rho - lat_tmp).^2);
                [lonind, latind] = find(dist == min(dist(:)));

                model_vari = [model_vari; vari(lonind, latind)];
                model_lon = [model_lon; g.lon_rho(lonind, latind)];
                model_lat = [model_lat; g.lat_rho(lonind, latind)];
            end % di

            disp([num2str(ti), ' / ', num2str(length(timenum_unique)), ' ...'])
        end % ti

        model_lon2 = obs_lon2;
        model_lat2 = obs_lat2;
        model_vari2 = griddata(model_lon, model_lat, model_vari, model_lon2, model_lat2);

        save([vari_str, '_ROMS_trawl_', ystr, '.mat'], 'model_lon2', 'model_lat2', 'model_vari2');
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
    pobs = plot_contourf(obs_lat2, obs_lon2, obs_vari2, contour_interval, climit, color);
    if strcmp(vari_str, 'botT')
        [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_vari2, [2 2], '-k', 'LineWidth', 4);
        l = legend(h2, '2 ^oC isotherm');
        l.Location = 'NorthWest';
        l.FontSize = 15;
    end

    %     if obsplotind == 1
    %         [cs2, h2] = contourm(obs_lat2, obs_lon2, obs_st2, [2 2], '-k', 'LineWidth', 4);
    %     end
    %     l = legend(h2, '2 ^oC isotherm');
    %     l.Location = 'NorthWest';
    %     l.FontSize = 15;
    title(['Trawl survey ', vari_str], 'FontSize', 15)

    nexttile(2)
    plot_map('Eastern_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    %     pmodel = pcolorm(model_lat2, model_lon2, model_st2);
    %     colormap jet;
    %     uistack(pmodel,'bottom')
    %     caxis(climit)
    pmodel = plot_contourf(model_lat2, model_lon2, model_vari2, contour_interval, climit, color);
    if strcmp(vari_str, 'botT')
        [cs2, h2] = contourm(model_lat2, model_lon2, model_vari2, [2 2], '-k', 'LineWidth', 4);
    end

    c = colorbar;
    c.Title.String = '^oC';
    title(['ROMS ', vari_str], 'FontSize', 15)

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    title(t, [ystr, ' (', datestr(min(timenum_unique), 'mmm dd'), ' - ', datestr(max(timenum_unique), 'mmm dd'), ')'], 'FontSize', 25)
    
    print(['cmp_', vari_str, '_w_trawl_', ystr], '-dpng')
end