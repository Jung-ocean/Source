function [uscale, vscale, lon_scl] = adjust_vector(lon, lat, u, v)

% Adjust the velocity vectors to account for the geographical coordinate system
lat_dist=distance('rh',[lat(1,1) lon(1,1)],[lat(1,1)+1 lon(1,1)],almanac('earth', 'ellipsoid', 'km'));

if isscalar(lat) == 1 | isvector(lat) == 1
    for i = 1:length(lat)
        lon_scl(i,1) = lat_dist./distance('rh',[lat(i) lon(i)],[lat(i) lon(i)+1],almanac('earth', 'ellipsoid', 'km'));
    end
else
    for i=1:size(lat,2)
        lon_scl(:,i)=lat_dist./distance('rh',[lat(1,i) lon(1,i)],[lat(1,i) lon(1,i)+1],almanac('earth', 'ellipsoid', 'km'));
    end
    lon_scl = repmat(lon_scl, [size(lat,1),1]);
end

uscale = u.*lon_scl;
vscale = v;