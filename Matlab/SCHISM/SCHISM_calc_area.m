function area=SCHISM_calc_area(lon, lat)
% Calculate SCHISM grid area (km^2)

wgs84 = wgs84Ellipsoid("km");

lat_tmp = [lat; lat(1)];
lon_tmp = [lon; lon(1)];

area = areaint(lat_tmp, lon_tmp, wgs84);