function [lon, lat, vari] = load_ADT_CMEMS_monthly(yyyy, mm)

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

SSH_filepath = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly_from_daily/'];
fileinfo = dir([SSH_filepath, '*', ystr, mstr, '*']);
SSH_filename = fileinfo.name;
SSH_file = [SSH_filepath, SSH_filename];

lon = ncread(SSH_file, 'longitude');
lat = ncread(SSH_file, 'latitude');
ADT = ncread(SSH_file, 'adt');

index1 = find(lon > 0); 
index2 = find(lon < 0);
ADT = [ADT(index1,:); ADT(index2,:)];
lon = lon - 180;

vari = ADT;

end