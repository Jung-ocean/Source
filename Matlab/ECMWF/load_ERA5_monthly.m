function [lon, lat, vari] = load_ERA5_monthly(yyyy, mm, vari_str, lon_target, lat_target)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/Models/ERA5/monthly/'];
filename = ['ERA5_', ystr, mstr, '.nc';];
file = [filepath, filename];

lon_tmp = ncread(file, 'longitude');
lon_tmp = lon_tmp - 360;
lonind = find(lon_tmp > min(lon_target)-1 & lon_tmp < max(lon_target)+1);
lon = double(lon_tmp(lonind));
lat_tmp = ncread(file, 'latitude');
latind = find(lat_tmp > min(lat_target)-1 & lat_tmp < max(lat_target)+1);
lat = double(lat_tmp(latind));

vari = ncread(file, vari_str, [lonind(1) latind(1) 1], [length(lonind) length(latind), 1]);

end