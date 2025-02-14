%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot z26.8 using ROMS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

lat_target = 58;
wgs84 = wgs84Ellipsoid("km");
lon_dist = distance(lat_target,0,lat_target,1,wgs84);
sigma_theta_target = 26.8;

load(['z', replace(num2str(sigma_theta_target), '.', '_'), '_lat_', num2str(lat_target)])

dist_from_coast = lon_dist.*abs(lon_target - lon_target(end));

% Figure properties
interval = 10;
climit = [100 700];
contour_interval_SSS = climit(1):interval:climit(2);
contour_interval_Sbar = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'm';

[xx, yy] = meshgrid(dist_from_coast, timenum);

figure; hold on; grid on;
set(gcf, 'Position', [1 1 500 1000]);
[cs, T] = contourf(xx, yy, z26_8, contour_interval_SSS, 'LineColor', 'none');
set (gca, 'xdir', 'reverse')
xlim([900 2500])
caxis(climit)
colormap(color)
c = colorbar;
c.Title.String = unit;
yticks([datenum(2019,1:12,1), datenum(2020,1:12,1), datenum(2021,1:12,1), datenum(2022,1:12,1)])
datetick('y', 'mmm, yyyy', 'keeplimits', 'keepticks')
xlabel('Distance from the eastern coast (km)')

timenum_guide = datenum(2021,1,1);
guide_line_1 = 1 * 1e-5 * 86400; % km/day 1 cm/s
guide_line_2 = 2 * 1e-5 * 86400; % km/day 2 cm/s
guide_line_3 = 3 * 1e-5 * 86400; % km/day 3 cm/s

plot([1000 3000], [timenum_guide timenum_guide+3000*1/guide_line_1], '--k')
text(1300, 738826, '1 cm/s', 'Color', 'k')
plot([1000 3000], [timenum_guide timenum_guide+3000*1/guide_line_2], '--k')
text(1700, 738826, '2 cm/s', 'Color', 'k')
plot([1000 3000], [timenum_guide timenum_guide+3000*1/guide_line_3], '--k')
text(2100, 738826, '3 cm/s', 'Color', 'k')

ylim([min(timenum) max(timenum)])

ax1 = gca;
xtick_ax1 = get(gca, 'XTick');
ax2 = axes('Position',ax1.Position,'XAxisLocation','top', 'color','none');
ax2.YTick = [];
ax2.XTick = xtick_ax1;
xlim([900 2500])
set (gca, 'xdir', 'reverse');
lon_label = -(xtick_ax1./lon_dist) + lon_target(end) + 360;
xticklabels(lon_label)
xlabel('Longitude (^oE)')

title(['z', num2str(sigma_theta_target), ' (latitude ', num2str(lat_target), '^oN)'])

print(['z', replace(num2str(sigma_theta_target), '.', '_'), '_lat_', num2str(lat_target)], '-dpng')