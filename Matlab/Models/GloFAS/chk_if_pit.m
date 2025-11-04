%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Check if selected river source points are pits
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc;

% User defined variables
yyyy = 9999;
filepath_all = '/data/jungjih/Models/GloFAS/';

ystr = num2str(yyyy);
filepath = [filepath_all, ystr, '/'];
if yyyy == 9999
    filepath = [filepath_all, 'climate/'];
end
filenames = dir([filepath, '*.nc']);

len_lat = length(ncread([filepath,filenames(1).name], 'lat'));
len_lon = length(ncread([filepath,filenames(1).name], 'lon'));

dis_total = zeros(yeardays(yyyy), len_lat,len_lon);
daynums = [0, cumsum(eomday(yyyy,1:12))];
for fi = 1:length(filenames)
    filename = filenames(fi).name;
    mm_str = filename(17:18);
    file = [filepath, filename];
    longitude = ncread(file,'lon');
    latitude = ncread(file,'lat');
    time = ncread(file,'time');
    dis24 = ncread(file,'dis24');
    dis24 = permute(dis24, [3 2 1]);
    daynum = (daynums(fi)+1):daynums(fi+1);
    dis_total(daynum,:,:) = dis24;
end
dis = squeeze(sum(dis_total,1));

f1 = figure; hold on;
set(gcf, 'Position', [1 200 800 500])
pcolor(longitude, latitude, dis);
colormap(jet(20))
xlim([min(longitude)-.1 max(longitude)+.1])
ylim([min(latitude)-.1 max(latitude)+.1])
caxis([0 1e5])
c = colorbar;
c.Title.String = 'm^3/s';
c.Title.FontSize = 8;
xlabel('Longitude');
ylabel('Latitude');
set(gca, 'FontSize', 12)
title(['Sum of GloFAS discharge in ', ystr], 'FontSize', 10)

diff_lon = abs(longitude(2) - longitude(1));
diff_lat = abs(latitude(2) - latitude(1));

% ldd
filepath = '/data/jungjih/Models/GloFAS/Auxiliary/';
filename = 'ldd_glofas_v4_0.nc';
file = [filepath, filename];

lon = ncread(file, 'lon');
lon(lon < 0) = lon(lon < 0)+360;
lat = ncread(file, 'lat');
ldd = ncread(file, 'ldd');

index = find(ldd == 5);
[lat2, lon2] = meshgrid(lat, lon);

plot(lon2(index)+diff_lon/2, lat2(index)-diff_lat/2, 'kx', 'MarkerSize', 15, 'LineWidth', 4)

% River source point
load /data/jungjih/Models/GloFAS/river_source_points.mat
plot(lon_dis_target+diff_lon/2, lat_dis_target-diff_lat/2, 'go', 'MarkerSize', 15, 'LineWidth', 4)