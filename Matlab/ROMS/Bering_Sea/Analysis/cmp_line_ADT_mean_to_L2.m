%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ADT along the specific line using ROMS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% Line numbers
direction = 'a';
if strcmp(direction, 'p')
    lines = 1:16; % pline
else
    lines = 3:3; % aline
end

yyyy_all = 2019:2023;
mm_all = 8:8;

isdemean = 0;
isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

xlimit = [180 187.5];

if isdemean == 1
    ylimit_obs = [-25 5];
    ylimit_model = ylimit_obs;
else
    ylimit_obs = [15 75];
    ylimit_model = [-35 25];
end

filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/zeta/vs_L2/v5.2/';
ADT = load([filepath, 'ADT_model_obs_', direction, 'line.mat']);
ADT = ADT.ADT;
lines_all = cell2mat(ADT.line);
timenum_all = cell2mat(ADT.time);

% Load grid information
g = grd('BSf');
lon_range = [min(min(g.lon_rho)) max(max(g.lon_rho))]; lat_range = [min(min(g.lat_rho)) max(max(g.lat_rho))]; % Bering Sea

h1 = figure; hold on;
set(gcf, 'Position', [1 1 1800 900])
t = tiledlayout(length(yyyy_all),3);

nexttile(1, [length(yyyy_all) 1])
plot_map('Gulf_of_Anadyr', 'mercator', 'l');
[C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'Color', 'k');

for li = 1:length(lines)
    
    line = lines(li);
    lstr = num2str(line, '%02i');

    lon_line = ADT.lon{line};
    lat_line = ADT.lat{line};

    if li == 1
        p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
        lon_line_dist1 = abs(lon_line - (xlimit(1) - 360));
        index1 = find(lon_line_dist1 == min(lon_line_dist1));
        lon_line_dist2 = abs(lon_line - (xlimit(2) - 360));
        index2 = find(lon_line_dist2 == min(lon_line_dist2));
        plotm(lat_line([index1:index2]), lon_line([index1:index2]), '-r', 'LineWidth', 2);
    else
        nexttile(1)
        delete(p)
        p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
    end
    
    index = find(lines_all == line);
            
    chk = 1;
    len_data = length(ADT.model{index(chk)});
    while len_data == 1
        chk = chk+1;
        len_data = length(ADT.model{index(chk)});
    end

    timenum_all = [];
    ADT_obs_all = NaN(len_data, length(index));
    ADT_model_all = NaN(len_data, length(index));
    for i = 1:length(index)
        timenum_all = [timenum_all; ADT.time{index(i)}];
        ADT_obs_tmp = ADT.obs{index(i)};
        ADT_model_tmp = ADT.model{index(i)};
        if isfilter == 1
            nanind = find(isnan(ADT_obs_tmp) == 1);
            ADT_obs_tmp = smoothdata(ADT_obs_tmp, 'gaussian', filter_window);
            ADT_obs_tmp(nanind) = NaN;

            nanind = find(isnan(ADT_model_tmp) == 1);
            ADT_model_tmp = smoothdata(ADT_model_tmp, 'gaussian', filter_window);
            ADT_model_tmp(nanind) = NaN;
        end
        if isdemean == 1
            ADT_obs_all(:,i) = ADT_obs_tmp - mean(ADT_obs_tmp, 'omitnan');
            ADT_model_all(:,i) = ADT_model_tmp - mean(ADT_model_tmp, 'omitnan');
        else
            ADT_obs_all(:,i) = ADT_obs_tmp;
            ADT_model_all(:,i) = ADT_model_tmp;
        end
    end

lon_plot = lon_line+360;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    time_start = datenum(yyyy,mm_all(1),1)-1;
    time_end = datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)))+1;
    tindex = find(timenum_all > time_start & timenum_all < time_end);
    timenum_tmp = timenum_all(tindex);
    ADT_obs_tmp = ADT_obs_all(:,tindex);
    ADT_model_tmp = ADT_model_all(:,tindex);

% Obs
ax = nexttile(2+3*(length(yyyy_all)-1)-3*(yi-1)); hold on; grid on;
lon_diff = diff(lon_plot);
index = find(lon_diff > 1.5*median(lon_diff));

for ti = 1:length(timenum_tmp)
if ~isempty(index)
    pindex = [0; index; length(lon_plot)];
    for pi = 1:length(pindex)-1
        if length(pindex(pi)+1:pindex(pi+1)) > 1
                plot(lon_plot(pindex(pi)+1:pindex(pi+1)), ADT_obs_tmp(pindex(pi)+1:pindex(pi+1),ti)'*100, 'Color', [.9 .6 .6]);
        end
    end
else
    plot(lon_plot, ADT_obs_tmp(:,ti)'*100, 'Color', [.9 .6 .6]);
end
end

ADT_obs_tmp_mean = mean(ADT_obs_tmp,2);
ADT_obs_mean(yi,:) = ADT_obs_tmp_mean;
plot(lon_plot, ADT_obs_tmp_mean*100, 'r', 'LineWidth', 2);

xlim(xlimit)
xtl = str2num(cell2mat(get(gca, 'Xticklabels')));
set(gca, 'Xticklabels', abs(xtl - 360));
ylim(ylimit_obs)
if yi == 1
    xlabel('Longitude (^oW)')
end
ylabel('cm')
if yi == length(yyyy_all)
    title({'Observation', ystr}, 'FontSize', 12)
else
    title(ystr, 'FontSize', 12)
end

% Model
ax = nexttile(3+3*(length(yyyy_all)-1)-3*(yi-1)); hold on; grid on;
lon_diff = diff(lon_plot);
index = find(lon_diff > 1.5*median(lon_diff));

for ti = 1:length(timenum_tmp)
if ~isempty(index)
    pindex = [0; index; length(lon_plot)];
    for pi = 1:length(pindex)-1
        if length(pindex(pi)+1:pindex(pi+1)) > 1
            plot(lon_plot(pindex(pi)+1:pindex(pi+1)), ADT_model_tmp(pindex(pi)+1:pindex(pi+1),ti)'*100, 'Color', [.7 .7 .7]);
        end
    end

else
    plot(lon_plot, ADT_model_tmp(:,ti)'*100, 'Color', [.7 .7 .7]);
end
end

ADT_model_tmp_mean = mean(ADT_model_tmp,2);
ADT_model_mean(yi,:) = ADT_model_tmp_mean;
plot(lon_plot, ADT_model_tmp_mean*100, 'k', 'LineWidth', 2);

xlim(xlimit)
xtl = str2num(cell2mat(get(gca, 'Xticklabels')));
set(gca, 'Xticklabels', abs(xtl - 360));
xticklabels
ylim(ylimit_model)
if yi == 1
    xlabel('Longitude (^oW)')
end
ylabel('cm')
if yi == length(yyyy_all)
    title({'Model', ystr}, 'FontSize', 12)
else
    title(ystr, 'FontSize', 12)
end

end

t.TileSpacing = 'compact';
t.Padding = 'compact';

pause(1)
print([direction, 'line_', lstr, '_zeta_mean_ROMS'], '-dpng');

% % Make gif
% gifname = [direction, 'line_zeta_ROMS.gif'];
% 
% frame = getframe(h1);
% im = frame2im(frame);
% [imind,cm] = rgb2ind(im,256);
% if li == 1
%     imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
% else
%     imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
% end

end % li