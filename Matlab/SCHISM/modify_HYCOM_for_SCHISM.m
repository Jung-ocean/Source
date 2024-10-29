clear; clc

start_date = '20190701';
runday = 153;

filepath_HYCOM = '/data/sdurski/HYCOM_extract/Bering_Sea/';

infofile = '/data/sdurski/HYCOM_extract/Bering_Sea/2019Y/HYCOM_glbyBeringSea_20190701.nc';
lon = ncread(infofile, 'Longitude');
lon = lon(:,1)+360;
lat = ncread(infofile, 'Latitude');
lat = lat(1,:);
depth = ncread(infofile, 'depths');

datenum_start = datenum(start_date, 'yyyymmdd');
datenum_all = datenum_start:datenum_start+153;

for i = 1:length(datenum_all)
    datenum_target = datenum_all(i);
    yyyymmdd = datestr(datenum_target, 'yyyymmdd');
    yyyy = datestr(datenum_target, 'yyyy');

    filepath = [filepath_HYCOM, yyyy, 'Y/Time_Filtered/'];
    filename = ['HYCOM_glbyBeringSea_', yyyymmdd, '.nc'];
    file = [filepath, filename];

    ssh = ncread(file, 'ssh');
    ssh(ssh == 0) = NaN;
    u = ncread(file, 'u');
    v = ncread(file, 'v');
    Temp = ncread(file, 'Temp');
    Salt = ncread(file, 'Salt');

    newfile = ['HYCOM_', yyyymmdd, '.nc'];
    make_empty_HYCOM_for_SCHISM(newfile,length(lat),length(lon),length(depth));

    ncwrite(newfile, 'ylat', lat);
    ncwrite(newfile, 'xlon', lon);
    ncwrite(newfile, 'time', (datenum_target-datenum(2000,1,1))*24);
    ncwrite(newfile, 'depth', depth);
    ncwrite(newfile, 'surf_el', ssh);
    ncwrite(newfile, 'salinity', Salt);
    ncwrite(newfile, 'water_u', u);
    ncwrite(newfile, 'water_v', v);
    ncwrite(newfile, 'temperature', Temp);

%     command = ['ln -sf ', pwd, '/', newfile, ' ../SSH_', num2str(i), '.nc'];
%     system(command);
%     command = ['ln -sf ', pwd, '/', newfile, ' ../TS_', num2str(i), '.nc'];
%     system(command);
%     command = ['ln -sf ', pwd, '/', newfile, ' ../UV_', num2str(i), '.nc'];
%     system(command);

end