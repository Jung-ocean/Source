%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS ADT along the specific line to Merged podaac
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% Line numbers
direction = 'a';
if strcmp(direction, 'p')
    lines = 3:3; % pline
else
    lines = 11:11; % aline
end

xlimit = [170 177.5];
climit1 = [-20 20];
climit2 = climit1;

ADT = load(['ADT_model_obs_', direction, 'line.mat']);
ADT = ADT.ADT;
lines_all = cell2mat(ADT.line);
timenum_all = cell2mat(ADT.time);

isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

h1 = figure; hold on;
set(gcf, 'Position', [1 1 800 800])
t = tiledlayout(1,2);

for li = 1:length(lines)
    
    line = lines(li);
    lstr = num2str(line, '%02i');

    lon_line = ADT.lon{line};
    lat_line = ADT.lat{line};
    
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
        ADT_obs_all(:,i) = ADT_obs_tmp;
        ADT_model_all(:,i) = ADT_model_tmp;
    end

    ADT_obs_all = ADT_obs_all - mean(ADT_obs_all(:), 'omitnan');
    ADT_model_all = ADT_model_all - mean(ADT_model_all(:), 'omitnan');

lon_plot = lon_line+360;

% Plot observation
ax1 = nexttile(1); cla; hold on; grid on
lon_diff = diff(lon_plot);
index = find(lon_diff > 1.5*median(lon_diff));
if ~isempty(index)
    pindex = [0; index; length(lon_plot)];
    for pi = 1:length(pindex)-1
        if length(pindex(pi)+1:pindex(pi+1)) > 1
            pcolor(lon_plot(pindex(pi)+1:pindex(pi+1)), timenum_all, ADT_obs_all(pindex(pi)+1:pindex(pi+1),:)'*100); shading interp
        end
    end
else
    pcolor(lon_plot, timenum_all, ADT_obs_all'*100); shading flat
end
colormap('jet(40)')
caxis(climit1)

xlim(xlimit)
ylim([timenum_all(1)-10 timenum_all(end)+10])
datetick('y', 'mmm dd, yyyy', 'keeplimits')

% Plot model
ax2 = nexttile(2); cla; hold on; grid on
lon_diff = diff(lon_plot);
index = find(lon_diff > 1.5*median(lon_diff));
if ~isempty(index)
    pindex = [0; index; length(lon_plot)];
    for pi = 1:length(pindex)-1
        if length(pindex(pi)+1:pindex(pi+1)) > 1
            pcolor(lon_plot(pindex(pi)+1:pindex(pi+1)), timenum_all, ADT_model_all(pindex(pi)+1:pindex(pi+1),:)'*100); shading interp
        end
    end
else
    pcolor(lon_plot, timenum_all, ADT_model_all'*100); shading flat
end
colormap('jet(40)')
caxis(climit2)

xlim(xlimit)
ylim([timenum_all(1)-10 timenum_all(end)+10])
datetick('y', 'mmm dd, yyyy', 'keeplimits')
yticklabels('')

c = colorbar;
c.Title.String = 'cm';

xlabel('Longitude')

title([direction, 'line ', num2str(line, '%02i')])

t.TileSpacing = 'compact';
t.Padding = 'compact';
dfdf
pause(1)
print([direction, 'line_', lstr, '_zeta_ROMS'], '-dpng');

end % li