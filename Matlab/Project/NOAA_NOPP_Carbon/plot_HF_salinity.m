clear; clc

filepath = '/data/jungjih/Observations/Yaquina_Bay/time_series/';
filename = 'HF_surface_TCSP.csv';
file = [filepath, filename];

lon = -124.043115;
lat = 44.624501;

data = readtable(file);
timenum = datenum(table2array(data(:,1)));
SSS = table2array(data(:,4));

figure;
set(gcf, 'Position', [1 200 1500 500]);
t = tiledlayout(1,4);
t.Padding = 'compact';
t.TileSpacing = 'tight';

nexttile(1); hold on;
g = grd('Oregon_1km');
pcolor(g.lon_rho, g.lat_rho, g.mask_rho./g.mask_rho); shading flat
plot(lon, lat, 'xr', 'MarkerSize', 15, 'LineWidth', 4);
xlim([-125 -123.5])
ylim([43 47])
xlabel('Longitude')
ylabel('Latitude')
set(gca, 'FontSize', 12)

nexttile(2,[1 3]); hold on; grid on;
plot(timenum, SSS, '-k');
xticks([datenum(2020,1:12,1) datenum(2021,1:12,1) datenum(2022,1:12,1) datenum(2023,1:12,1)])
xlim([timenum(1)-1 timenum(end)+1]);
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
ylabel('Salinity (psu)')
set(gca, 'FontSize', 12)
title('Hatfield Marine Science Center', 'FontSize', 20);

print('HF_salinity', '-dpng')