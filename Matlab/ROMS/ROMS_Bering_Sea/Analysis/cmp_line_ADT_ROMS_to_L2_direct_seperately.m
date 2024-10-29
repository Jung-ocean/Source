%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta and along-track ADT from Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

% Line numbers
direction = 'a';
if strcmp(direction, 'p')
    lines = 1:15; % pline
else
%     lines = 1:24; % aline
    lines = 1:7; % aline
end

isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

xlimit = [154 203];
% xlimit = [175 187.5];
ylimit = [-20 30];

yyyy_all = 2018:2022;

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
ADT = load(['ADT_model_obs_', direction, 'line.mat']);
ADT = ADT.ADT;
lines_all = cell2array(ADT.line);
lines_unique = unique(lines_all);
timenum_all = cell2array(ADT.time);

for li = 1:length(lines)
    line = lines(li); lstr = num2str(line, '%02i');
    lon_line = ADT.lon{line}+360;
    lat_line = ADT.lat{line};
    
    if strcmp(direction, 'p') == 1
    h_interp = interp2(g.lon_rho+360, g.lat_rho, g.h, lon_line, lat_line);
    dist = abs(h_interp - 200);
    hindex = find(dist == min(dist));
    while lon_line(hindex) < median(lon_line)
        h_interp(hindex) = 1000;
        dist = abs(h_interp - 200);
        hindex = find(dist == min(dist));
    end
    end
    
    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);

        for mi = 3:3%1:size(date.month,1)
            % Figure
            h1 = figure; hold on; grid on
            set(gcf, 'Position', [1 1 1000 500])
            title([direction, 'line ', lstr, ' (', date.label{mi}, ', ', ystr, ')'], 'FontSize', 15);

            mms = date.month(mi,:);
            time_start = datenum(yyyy,mms(1),1)-1;
            time_end = datenum(yyyy,mms(end)+1,1);

            index = find(lines_all == line & ...
                timenum_all > time_start & ...
                timenum_all < time_end);

            ADT_obs = [];
            ADT_model = [];
            for ii = 1:length(index)
                ADT_obs = [ADT_obs; ADT.obs{index(ii)}];
                if isscalar(ADT.model{index(ii)}) == 1
                    ADT_model = [ADT_model; NaN([1, size(ADT_model,2)])];
                else
                    ADT_model = [ADT_model; ADT.model{index(ii)}];
                end
            end

            ADT_obs_season = mean(ADT_obs,1, 'omitnan');
            if isempty(ADT_model) == 1
                ADT_model_season = NaN(size(lon_line))';
            else
                ADT_model_season = mean(ADT_model,1, 'omitnan');
                if isscalar(ADT_model_season) == 1
                    ADT_model_season = NaN(size(lon_line))';
                end
            end

            ADT_obs_mean = mean(ADT_obs_season, 'omitnan');
            ADT_obs_season(ADT_obs_season < ADT_obs_mean-0.4) = NaN;
            ADT_obs_season(ADT_obs_season > ADT_obs_mean+0.4) = NaN;

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

            if strcmp(direction, 'p') == 1 && min(dist) < 50
                plot(zeros(1,201)+lon_line(hindex), -100:100, 'Color', [.7 .7 .7], 'LineWidth', 4)
            end

%             mean_obs = mean(ADT_obs_season, 'omitnan');
%             std_obs = std(ADT_obs_season, 'omitnan');
%             upper = mean_obs + std_obs;
%             lower = mean_obs - std_obs;
%             index = find(ADT_obs_season < lower | ADT_obs_season > upper);
%             ADT_obs_season(index) = NaN;

            ADT_obs_adj = 100*(ADT_obs_season-mean(ADT_obs_season, 'omitnan'));
            ADT_model_adj = 100*(ADT_model_season - mean(ADT_model_season, 'omitnan'));

            jump = find(diff(lon_line) > 0.2);
            if ~isempty(jump)
                index = [0];
                for ii = 1:length(jump)
                    index = [index; jump(ii)];
                end
                index = [index; length(lon_line)];
                for pi = 1:length(index)-1
                    po = plot(lon_line(index(pi)+1:index(pi+1)), ADT_obs_adj(index(pi)+1:index(pi+1)), 'Color', date.color{mi}, 'LineWidth', 1);
                    pm = plot(lon_line(index(pi)+1:index(pi+1)), ADT_model_adj(index(pi)+1:index(pi+1)), 'Color', 'k', 'LineWidth', 1);
                end

            else
                po = plot(lon_line, ADT_obs_adj, 'Color', date.color{mi}, 'LineWidth', 1);
                pm = plot(lon_line, ADT_model_adj, 'Color', 'k', 'LineWidth', 1);
            end

            R(li,yi,mi) = corr(ADT_obs_adj',ADT_model_adj', 'rows', 'complete');

            xlim(xlimit)
            ylim(ylimit)

            xlabel('Longitude')
            ylabel('cm')

            l = legend([po, pm], 'Satellite L2', 'ROMS');
            l.Location = 'NorthWest';
            l.FontSize = 15;
        end

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

        set(gcf, 'Position', [1 1 1000 500])
        pause(3)
        print(['cmp_line_ADT_L2_direct_', direction, 'line_', lstr, '_', ystr, '_', date.label{mi}], '-dpng')
    end
end