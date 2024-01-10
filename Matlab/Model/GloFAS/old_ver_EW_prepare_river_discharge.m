%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Preperation for ROMS river input forcing using GloFAS data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

% User defined variables
yyyy = 1979; 
filepath_all = '/data/jungjih/Model/GloFAS/';
cutoff = 10000;
%

ROMS_grid_file = '/data/sdurski/ROMS_Setups/Grids/Bering_Sea/BeringSea_Dsm_grid.nc.old';
mask_rho = ncread(ROMS_grid_file, 'mask_rho');
lon_rho = ncread(ROMS_grid_file, 'lon_rho');
lat_rho = ncread(ROMS_grid_file, 'lat_rho');
mask_rho = mask_rho';
lon_rho = lon_rho';
lat_rho = lat_rho';

figure; hold on;
pcolor(lon_rho,lat_rho,mask_rho./mask_rho); shading flat
ylim([45 70])
xlim([140 210]-360)

ystr = num2str(yyyy);
filepath = [filepath_all, ystr, '/'];
filenames = dir([filepath, '*.nc']);

len_lat = length(ncread([filepath,filenames(1).name], 'lat'));
len_lonE = length(ncread([filepath,filenames(1).name], 'lon'));
len_lonW = length(ncread([filepath,filenames(2).name], 'lon'));

dis_total = zeros(yeardays(yyyy), len_lat,len_lonE+len_lonW);
for fi = 1:length(filenames)
    filename = filenames(fi).name;
    file = [filepath, filename];
    longitude = ncread(file,'lon');
    latitude = ncread(file,'lat');
    time = ncread(file,'time');
    daynum = datenum(datenum(1979,1,1) + double(time)/24) - datenum(yyyy,1,1);
    dis24 = ncread(file,'dis24');
    dis24 = permute(dis24, [3 2 1]);

    if strcmp(filename(end-3), 'E')
        longitude_tmp = longitude;
        dis24_tmp = dis24;
    elseif strcmp(filename(end-3), 'W')
        longitude = [longitude; longitude_tmp];
        dis_24_composite = cat(3, dis24, dis24_tmp);
        dis_total(daynum,:,:) = dis_24_composite;
    end
end
dis = squeeze(sum(dis_total,1));
%dis = squeeze(mean(dis_total,1));

f1 = figure; hold on; grid on
pcolor(longitude, latitude, dis); shading flat
xlim([min(longitude)-.1 max(longitude)+.1])
ylim([min(latitude)-.1 max(latitude)+.1])
caxis([0 50000])
c = colorbar;
c.Title.String = 'm^3/s';
c.Title.FontSize = 8;
xlabel('Longitude');
ylabel('Latitude');
set(gca, 'FontSize', 12)
title(['Sum of GloFAS discharge in ', ystr], 'FontSize', 10)
set(gcf, 'PaperPosition', [1.2812 3.3490 5.9375 4.3021])
set(gcf, 'PaperSize', [8.5 11.0])
print(['01_GloFAS_raw_', ystr],'-dpng')

f2 = figure; hold on; grid on
index = find(dis < cutoff);
dis(index) = 0;
pcolor(longitude, latitude, dis); shading flat
xlim([min(longitude)-.1 max(longitude)+.1])
ylim([min(latitude)-.1 max(latitude)+.1])
caxis([0 50000])
c = colorbar;
c.Title.String = 'm^3/s';
c.Title.FontSize = 8;
xlabel('Longitude');
ylabel('Latitude');
set(gca, 'FontSize', 12)
title(['Sum of GloFAS discharge (> ', num2str(cutoff, '%1.1e'), ') in ', ystr], 'FontSize', 10)
set(gcf, 'PaperPosition', [1.2812 3.3490 5.9375 4.3021])
set(gcf, 'PaperSize', [8.5 11.0])
print(['02_GloFAS_cutoff_', ystr],'-dpng')

radius = 2;
lat_dis = []; 
lon_dis = [];
for i = 1+radius:length(latitude)-radius
    for ii = 1+radius:length(longitude)-radius
        value = find_point(dis,i,ii,cutoff,radius);
        if value == 1
            lat_dis = [lat_dis, latitude(i)];
            lon_dis = [lon_dis, longitude(ii)];
        end
    end
end
xv = [-203 -197 -180 -156 -156 -203]+360;
yv = [52 60 68 68 52 52];
[in,on] = inpolygon(lon_dis,lat_dis,xv,yv);
lon_dis_target = double(lon_dis(in));
lat_dis_target = double(lat_dis(in));
figure(f2);
plot(lon_dis, lat_dis, '.r', 'MarkerSize', 12)
plot(lon_dis_target, lat_dis_target, '.g', 'MarkerSize', 12)
print(['03_GloFAS_cutoff_Bering_Sea_', ystr],'-dpng')

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
print(['04_GloFAS_cutoff_Bering_Sea_barplot_', ystr],'-dpng')

