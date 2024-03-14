function [lon_point, lat_point, dis_point] = find_point(lon2,lat2,dis,lon_target,lat_target,radius)

dist_from_point = distance(lat_target, lon_target, lat2, lon2);
[I,J] = find(dist_from_point < radius);

dis_dist = [];
lon_dist = [];
lat_dist = [];
for i = 1:length(I)
    dis_dist = [dis_dist; dis(I(i),J(i))];
    lon_dist = [lon_dist; lon2(I(i),J(i))];
    lat_dist = [lat_dist; lat2(I(i),J(i))];
end

index2 = find(dis_dist == max(dis_dist));
dis_point = dis_dist(index2);
lon_point = lon_dist(index2);
lat_point = lat_dist(index2);

end