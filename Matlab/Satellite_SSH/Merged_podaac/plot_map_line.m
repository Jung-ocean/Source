clear; clc; close all

direction = 'a';
if strcmp(direction, 'p')
    lines = 1:15; % pline
else
    lines = 1:24; % aline
end

% Load grid information
g = grd('BSf');

h1 = figure; hold on;
set(gcf, 'Position', [1 1 800 500])
plot_map('Bering', 'mercator', 'l');
[C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', [.7 .7 .7]);

for li = 1:length(lines)
    [lon_line, lat_line] = indices_lines_Bering_Sea_slope(direction, li);
    p = plotm(lat_line, lon_line, '-k', 'LineWidth', 2);
    if strcmp(direction, 'p')
        t = textm(lat_line(end), lon_line(end)+1, num2str(li, '%02i'), 'Color', 'r', 'FontSize', 15);
    else
        t = textm(lat_line(1), lon_line(1)-1, num2str(li, '%02i'), 'Color', 'r', 'FontSize', 15);
    end
end
title([direction, 'line'], 'Fontsize', 25)

print(['map_', direction, 'line'], '-dpng')