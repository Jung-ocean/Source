%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta and along-track ADT from Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';
lines = 1:13;

isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

yyyy_all = 2018:2021;

JFM = 1:3;
AMJ = 4:6;
JAS = 7:9;
OND = 10:12;

date.month = [JFM; AMJ; JAS; OND];
date.label = {'JFM', 'AMJ', 'JAS', 'OND'};
date.color = {'b', [0 0.4471 0.7412], 'r', [0.8510 0.3255 0.0980]};
date.linewidth = [3, 1, 3, 1];

% Load grid information
g = grd('BSf');

% Load ADT
ADT = load('ADT_model_obs.mat');
ADT = ADT.ADT;
lines = cell2array(ADT.line);
lines_unique = unique(lines);
timenum_all = cell2array(ADT.time);

for li = 1:length(lines_unique)
    line = lines_unique(li); lstr = num2str(line, '%02i');
    lon_line = ADT.lon{li}+360;
    lat_line = ADT.lat{li};

    h_interp = interp2(g.lon_rho+360, g.lat_rho, g.h, lon_line, lat_line);
    dist = abs(h_interp - 200);
    hindex = find(dist == min(dist));
    while lon_line(hindex) < median(lon_line)
        h_interp(hindex) = 1000;
        dist = abs(h_interp - 200);
        hindex = find(dist == min(dist));
    end
    
    % Figure
    h1 = figure; hold on;
    set(gcf, 'Position', [1 1 1800 500])
    t = tiledlayout(2,2);

    nexttile(1, [2 1])
    plot_map('Bering', 'mercator', 'l');
    [C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', [.7 .7 .7]);
    pm = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);

        for mi = 1:size(date.month,1)
            mms = date.month(mi,:);
            time_start = datenum(yyyy,mms(1),1)-1;
            time_end = datenum(yyyy,mms(end)+1,1);

            index = find(lines == line & ...
                timenum_all > time_start & ...
                timenum_all < time_end);

            ADT_obs = [];
            ADT_model = [];
            for ii = 1:length(index)
                ADT_obs = [ADT_obs; ADT.obs{index(ii)}];
                ADT_model = [ADT_model; ADT.model{index(ii)}];
            end

            if isempty(ADT_model) == 1
                ADT_obs_season = NaN(size(lon_line));
                ADT_model_season = NaN(size(lon_line));
            else
                ADT_obs_season = mean(ADT_obs,1, 'omitnan');
                ADT_model_season = mean(ADT_model,1, 'omitnan');
            end

            if isfilter == 1
                nanobs = find(isnan(ADT_obs_season)==1);
                ADT_obs_season_fill = fillmissing(ADT_obs_season,'linear',2,'EndValues','nearest');
                ADT_obs_season_filt = smoothdata(ADT_obs_season_fill, 'gaussian', filter_window);
                ADT_obs_season = ADT_obs_season_filt;
                ADT_obs_season(nanobs) = NaN;

                nanmodel = find(isnan(ADT_model_season)==1);
                ADT_model_season_fill = fillmissing(ADT_model_season,'linear',2,'EndValues','nearest');
                ADT_model_season_filt = smoothdata(ADT_model_season_fill, 'gaussian', filter_window);
                ADT_model_season = ADT_model_season_filt;
                ADT_model_season(nanmodel) = NaN;
            end

            nexttile(2);
            if mi == 1
                cla; hold on; grid on
            end
            p(mi) = plot(lon_line, 100*ADT_obs_season, 'Color', date.color{mi}, 'LineWidth', date.linewidth(mi));
            if min(dist) < 50
                plot(zeros(1,201)+lon_line(hindex), -100:100, '-k')
            end
            xlim([154 203])
            ylim([10 70])

            xlabel('Longitude')
            ylabel('cm')

            title(['Satellite L2 (', ystr, ')'])

            nexttile(4);
            if mi == 1
                cla; hold on; grid on
            end

            plot(lon_line, 100*ADT_model_season, 'Color', date.color{mi}, 'LineWidth', date.linewidth(mi));
            %     errorbar(lon_line, 100*zeta_mean, 100*zeta_std, 'Color', date.color{mi});
            if min(dist) < 50
                plot(zeros(1,201)+lon_line(hindex), -100:100, '-k')
            end
            xlim([154 203])
            ylim([-40 20])

            xlabel('Longitude')
            ylabel('cm')

            title(['ROMS (', ystr, ')'])
        end

        l = legend(p, date.label);
        l.Location = 'NorthWest';

        %     % Make gif
        %     gifname = ['cmp_line_ADT_L2_seasonally.gif'];
        %
        %     frame = getframe(h1);
        %     im = frame2im(frame);
        %     [imind,cm] = rgb2ind(im,256);
        %     if li == 1
        %         imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        %     else
        %         imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        %     end
        
        print(['cmp_line_ADT_L2_line_', lstr, '_', ystr], '-dpng')
    end
end
