%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot buoy locations
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'US_west';
g = grd('NANOOS');

stations = {
'Port Orford'    
'Umpqua Offshore'
'Yaquina Channel'
'OOI Newport Shelf'
'Stonewall Bank'
'Tillamook Bay'
'Clatsop Spit'
'Columbia River Bar'
'Astoria Canyon'
'Grays Harbor'
'OOI Westport Shelf'
'OOI Westport Offshore'
'Cape Elizabeth'
'Eel River'
'Humboldt Bay'
'St Georges'
'Neah Bay'
};

ids = [
46015
46229
46283
46097
46050
46278
46243
46029
46248
46211
46099
46100
46041
46022
46244
46027
46087
];

lats = [
42.754
43.772
44.567
44.639
44.669
45.561
46.214
46.163
46.133
46.857
46.988
46.851
47.352
40.716
40.896
41.840
48.493
];

lons = -[
124.839
124.549
124.237
124.304
124.546
123.991
124.126
124.487
124.64
124.243
124.567
124.964
124.739
124.540
124.358
124.382
124.727
];

figure; hold on;
set(gcf, 'Position', [1 200 500 800])
plot_map(map, 'mercator', 'l')
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [100 200 1000 2000], 'k');

for si = 1:length(stations)
    plotm(lats(si), lons(si), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');
end

print('location_buoy', '-dpng')

save('location_buoy.mat', 'stations', 'ids', 'lats', 'lons')