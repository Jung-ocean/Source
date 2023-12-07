clear; clc; close all

ncload results_LTRANS.nc

% NWP
%lon_point = [127.0000, 128.2000, 129.5500, 131.2000, 133.0000]; %, 135.4000];
%lat_point = [21.0000; 19.9933; 18.8608; 17.4767; 15.9667];% 13.9533];

% ECS
%lon_point = [129.24 127.75 126.248 125.248 125.248 125.248 126.248 127.249 128.742];
%lat_point = [34.90 33.83 33.75 33.28 32.48 31.48 32.48 33.38 34.14];

% Fukushima
lon_point = [141.0325 141.0325 141.0325];
lat_point = [37.4214 37.4214 37.4214];

g = grd('kimyy');

figure; hold on
map_J('NWP')

% for i = 1:length(dob)
%         h1 = m_plot(lon(:,i), lat(:,i), 'linewidth', 0.5, 'color', [.8510 .3294 .1020]);
% end

for i = 1:length(dob)
    h1 = m_plot(lon(end,i), lat(end,i), '.', 'MarkerSize', 7, 'color', [.8510 .3294 .1020]);
end

%for pi = 1:length(lon_point)
%    h2 = m_plot(lon_point(pi), lat_point(pi), '.r', 'MarkerSize', 30);
%end

%saveas(gcf, ['results.png'])