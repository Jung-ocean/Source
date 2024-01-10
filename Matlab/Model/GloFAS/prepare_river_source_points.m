%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preperation for ROMS river input forcing using GloFAS data
% You will need "find_point.m" file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

% User defined variables
yyyy = 9999;
filepath_all = '/data/jungjih/Model/GloFAS/';
filename_out = 'river_source_points.mat'; 
% If filename_out exists, filename_out will be new_filename_out 
%

ROMS_grid_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc';
mask_rho = ncread(ROMS_grid_file, 'mask_rho');
lon_rho = ncread(ROMS_grid_file, 'lon_rho');
lat_rho = ncread(ROMS_grid_file, 'lat_rho');
mask_rho = mask_rho'; lon_rho = lon_rho'; lat_rho = lat_rho';

% figure; hold on;
% pcolor(lon_rho,lat_rho,mask_rho./mask_rho); shading flat
% ylim([45 70])
% xlim([140 210]-360)

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

f1 = figure; hold on; grid on
pcolor(longitude, latitude, dis); shading flat
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
set(gcf, 'PaperPosition', [1.2812 3.3490 5.9375 4.3021])
set(gcf, 'PaperSize', [8.5 11.0])

[lon2,lat2] = meshgrid(longitude,latitude);
lon_ocean = lon2(isnan(dis)==1);
lat_ocean = lat2(isnan(dis)==1);
k = boundary(lon_ocean,lat_ocean,1);
lon_coast = lon_ocean(k);
lat_coast = lat_ocean(k);

radius = 0.5; % degree
lon_point_all = []; lat_point_all = []; dis_point_all = [];
for i = 1:length(k)
    lon_target = lon_coast(i);
    lat_target = lat_coast(i);
    
    [lon_point, lat_point, dis_point] = find_point(lon2,lat2,dis,lon_target,lat_target,radius);

    lon_point_all = [lon_point_all; lon_point];
    lat_point_all = [lat_point_all; lat_point];
    dis_point_all = [dis_point_all; dis_point];
end
p = plot(lon_point_all, lat_point_all, 'xr');
print(['01_GloFAS_all_river_source_points_', ystr],'-dpng')

dis_hist = dis_point_all;
pd = fitdist(log10(dis_hist(:)),'Normal');
figure; hold on; grid on
histfit(log10(dis_hist(:))); % Default nbin value is the square root of the number of elements in data, rounded up.
plot(zeros(1,201)+(pd.mu-pd.sigma), [0:200], '--k', 'LineWidth', 2)
xlabel('River discharge [log_1_0 m^3/s]')
ylabel('Frequency')
print(['02_GloFAS_river_discharge_hist_', ystr],'-dpng')

cutoff = 10^(pd.mu-pd.sigma);
index = find(dis_point_all > cutoff);

figure(f1); shading faceted;
delete(p);
plot(lon_point_all(index), lat_point_all(index), 'xr')
caxis([cutoff 1e5])
gi = 1;
    lonind_all = [];
    latind_all = [];
while gi == 1
    title('Zoom in or Zoom out and press any key')
    pause
    title('Select the river source (Continue: Click, End: Ctrl c)')
    [X,Y] = ginput(1);
    Xdist = X-longitude;
    Ydist = Y-latitude;

    lonind = find(Xdist > 0 & Xdist < 0.05);
    latind = find(Ydist < 0 & Ydist > -0.05);
    
    if ismember(lonind, lonind_all) && ismember(latind, latind_all)
        index = find(lonind_all == lonind);
        lonind_all(index) = [];
        latind_all(index) = [];
        plot(longitude(lonind), latitude(latind), 'or');
    else
        lonind_all = [lonind_all, lonind];
        latind_all = [latind_all, latind];
        plot(longitude(lonind), latitude(latind), 'og');
    end
end
lon_dis = longitude(lonind_all);
lat_dis = latitude(latind_all);

f2 = figure; hold on; grid on
pcolor(longitude, latitude, dis); shading flat
plot(lon_dis, lat_dis, 'or')
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
set(gcf, 'PaperPosition', [1.2812 3.3490 5.9375 4.3021])
set(gcf, 'PaperSize', [8.5 11.0])

xv = [-203 -197 -190 -177 -175 -173 -167 -165 -156 -156 -203]+360;
yv = [51 60 66.3 66.3 65 66.3 66.3 65 66.3 51 51];
[in,on] = inpolygon(lon_dis,lat_dis,xv,yv);
lon_dis_target = double(lon_dis(in));
lat_dis_target = double(lat_dis(in));
figure(f2);
plot(lon_dis_target, lat_dis_target, 'og')
print(['03_GloFAS_river_source_points_Bering_Sea_', ystr],'-dpng')

dis_total_target = zeros(yeardays(yyyy),length(lon_dis_target));
for i = 1:length(lon_dis_target)
    lat_ind = find(ismember(latitude,lat_dis_target(i)) == 1);
    lon_ind = find(ismember(longitude,lon_dis_target(i)) == 1);

    dis_total_target(:,i) = dis_total(:, lat_ind, lon_ind);
end
dis_total_target_sum = double(sum(dis_total_target,1));

[xx,yy] = meshgrid(lon_dis_target,lat_dis_target);
zz = griddata(lon_dis_target,lat_dis_target,dis_total_target_sum,xx,yy);

figure(f2);
for i = 1:length(lon_dis_target)
    h = bar3(dis_total_target_sum(i));
    xdata = get(h,'Xdata');
    set(h,'Xdata',xdata-1+lon_dis_target(i));
    ydata = get(h,'Ydata');
    set(h,'Ydata',ydata-1+lat_dis_target(i));
    set(h,'FaceColor', [0.0745 0.6235 1.0000])
end
caxis([0 50000])
set(gca, 'View', [-5.9063 20.1057])
set(gcf, 'Position', [30 300 900 600])
set(gcf, 'PaperPosition', [1.2812 3.3490 5.9375 4.3021])
set(gcf, 'PaperSize', [8.5 11.0])
zlabel('Discharge (m^3/s)')
print(['04_GloFAS_river_source_points_Bering_Sea_barplot_', ystr],'-dpng')

if isfile(filename_out)
    save(['new_', filename_out], 'lon_dis_target', 'lat_dis_target')
else
    save(filename_out, 'lon_dis_target', 'lat_dis_target')
end