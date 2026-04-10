function [lat, lon, vari] = load_SLA_sat_daily(timenum)

timevec = datevec(timenum);
yyyy = timevec(:,1);
mm = timevec(:,2);
dd = timevec(:,3);

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');
dstr = num2str(dd, '%02i');
yyyymmdd = [ystr, mstr, dstr];

SSH_filepath = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/daily/', ystr, '/', mstr, '/'];
fileinfo = dir([SSH_filepath, '*_', yyyymmdd, '_*']);
SSH_filename = fileinfo.name;
SSH_file = [SSH_filepath, SSH_filename];

lon = ncread(SSH_file, 'longitude');
lat = ncread(SSH_file, 'latitude');
SLA = ncread(SSH_file, 'sla');

index1 = find(lon > 0); 
index2 = find(lon < 0);
SLA = [SLA(index1,:); SLA(index2,:)];
lon = lon - 180;

vari = SLA;

end