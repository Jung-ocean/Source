function [uscale, vscale, lon_scl] = adjust_vector(lon, lat, u, v)

% Adjust the velocity vectors to account for the geographical coordinate system
lat_dist=distance('rh',[lat(1,1) lon(1,1)],[lat(1,1)+1 lon(1,1)],almanac('earth', 'ellipsoid', 'km'));

if isscalar(lat) == 1
    lon_scl = lat_dist./distance('rh',[lat lon],[lat lon+1],almanac('earth', 'ellipsoid', 'km'));
    uscale = u.*lon_scl;
    vscale = v;
else
    for i=1:size(lat,1)
        lon_scl(i,:)=lat_dist./distance('rh',[lat(i,1) lon(i,1)],[lat(i,1) lon(i,1)+1],almanac('earth', 'ellipsoid', 'km'));
    end
    lon_scl = repmat(lon_scl, [1,size(lat,2)]);
    uscale = u.*lon_scl;
    vscale = v;
end