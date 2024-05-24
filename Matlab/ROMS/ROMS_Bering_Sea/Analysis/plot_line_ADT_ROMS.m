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
    lines = 1:29; % aline
end

ADT = load(['ADT_model_obs_', direction, 'line.mat']);
ADT = ADT.ADT;
lines_all = cell2array(ADT.line);
timenum_all = cell2array(ADT.time);

isfilter = 0;
filter_window = 8; % 1 ~ 5.75 km

% Load grid information
g = grd('BSf');
lon_range = [min(min(g.lon_rho)) max(max(g.lon_rho))]; lat_range = [min(min(g.lat_rho)) max(max(g.lat_rho))]; % Bering Sea

h1 = figure; hold on;
set(gcf, 'Position', [1 1 1800 500])
t = tiledlayout(1,2);

nexttile(1)
plot_map('Bering', 'mercator', 'l');
[C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', [.7 .7 .7]);

for li = 1:length(lines)
    
    lstr = num2str(li, '%02i');

    lon_line = ADT.lon{li};
    lat_line = ADT.lat{li};

    if li == 1
        p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
    else
        nexttile(1)
        delete(p)
        p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
    end
    
    index = find(lines_all == li);

    timenum_all = [];
    ADT_all = NaN(length(ADT.model{index(end)}), length(index));
    for i = 1:length(index)
        timenum_all = [timenum_all; ADT.time{index(i)}];
        ADT_tmp = ADT.model{index(i)};
        if isfilter == 1
            nanind = find(isnan(ADT_tmp) == 1);
            ADT_tmp = smoothdata(ADT_tmp, 'gaussian', filter_window);
            ADT_tmp(nanind) = NaN;
        end
        ADT_all(:,i) = ADT_tmp;
    end

lon_plot = lon_line+360;

nexttile(2); cla; hold on; grid on

lon_diff = diff(lon_plot);
index = find(lon_diff > 0.2);
if ~isempty(index)
    pindex = [0; index; length(lon_plot)];
    for pi = 1:length(pindex)-1
        if length(pindex(pi)+1:pindex(pi+1)) > 1
            pcolor(lon_plot(pindex(pi)+1:pindex(pi+1)), timenum_all, ADT_all(pindex(pi)+1:pindex(pi+1),:)'*100); shading interp
        end
    end

else
    pcolor(lon_plot, timenum_all, ADT_all'*100); shading interp
end

ax = gca;
colormap(ax, 'parula')

%xlim([lon_plot(1)-0.1 lon_plot(end)+0.1])
xlim([154 203])
ylim([timenum_all(1)-10 timenum_all(end)+10])
datetick('y', 'mmm dd, yyyy', 'keeplimits')

caxis([20 60]-50)
c = colorbar;
c.Title.String = 'cm';

xlabel('Longitude')

title([direction, 'line ', num2str(li, '%02i')])

t.TileSpacing = 'compact';
t.Padding = 'compact';

pause(1)
print([direction, 'line_', lstr, '_zeta_ROMS'], '-dpng');

% Make gif
gifname = [direction, 'line_zeta_ROMS.gif'];

frame = getframe(h1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if li == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

end % li