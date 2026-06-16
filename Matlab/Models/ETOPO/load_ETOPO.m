function ETOPO = load_ETOPO(casename)

[lon_limit, lat_limit] = load_domain(casename);

filepath = '/data/jungjih/Models/ETOPO/';
filename = 'ETOPO_2022_v1_60s_N90W180_bed.nc';
file = [filepath, filename];

lat = ncread(file, 'lat');
lon = ncread(file, 'lon');
index1 = find(lon < 0);
index2 = find(lon > 0);
lon = [lon(index2)-360; lon(index1)];
z = ncread(file, 'z');
z = [z(index2, :); z(index1, :)];

lonind = find(lon > lon_limit(1)-1 & lon < lon_limit(2)+1);
latind = find(lat > lat_limit(1)-1 & lat < lat_limit(2)+1);
lon_target = lon(lonind);
lat_target = lat(latind);
[lat2, lon2] = meshgrid(lat_target, lon_target);
z_target = z(lonind, latind);

ETOPO.lat = lat2;
ETOPO.lon = lon2;
ETOPO.h = -z_target;

disp(['Loading ETOPO ', casename, ' domain']);

end