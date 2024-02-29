clear; clc

filename_out = 'ideal.tif';
coordRefSysCode = 4326; % WGS84

lon_target = [-165 -160];
lat_target = [55 60];

lon = lon_target(1):1/60:lon_target(2);
lat = lat_target(1):1/60:lat_target(2);
surface = zeros(length(lat), length(lon));

x = 1:length(lon);
depth_line = 100 - x.*(500./length(lon));
for yi = 1:length(lat)
    surface(yi,:) = fliplr(depth_line);
end

R = georasterref('RasterSize',size(surface),'LatitudeLimits',[min(lat),max(lat)],'LongitudeLimits',[min(lon),max(lon)]);

tiffile = filename_out;
geotiffwrite(tiffile,surface, R, 'CoordRefSysCode', coordRefSysCode)

figure
plot_map('Bering', 'mercator', 'l')
geoshow(tiffile, 'DisplayType','surface')

info = geotiffinfo('ideal.tif');
crs = info.SpatialRef.GeographicCRS;