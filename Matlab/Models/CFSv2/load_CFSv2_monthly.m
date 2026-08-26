function [lon, lat, vari] = load_CFSv2_monthly(yyyy, mm, vari_str, lon_target, lat_target)

switch vari_str
    case 'DSWRF_surface'
        vari_filename = 'dswsfc';
    case 'USWRF_surface'
        vari_filename = 'uswsfc';
    case {'UGRD_10maboveground', 'VGRD_10maboveground'}
        vari_filename = 'wnd10m';
    case 'TMP_2maboveground'
        vari_filename = 'tmp2m';
end

ystr = num2str(yyyy);
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/Models/CFSv2/netcdf_sub/'];
filename = [vari_filename, '_', ystr, '.nc'];
file = [filepath, filename];

time = ncread(file, 'time');
timenum = time/60/60/24 + datenum(1970,1,1);
timevec = datevec(timenum);
tindex = find(timevec(:,1) == yyyy & timevec(:,2) == mm);

lon_tmp = ncread(file, 'longitude');
lon_tmp = lon_tmp - 360;
lonind = find(lon_tmp > min(lon_target)-1 & lon_tmp < max(lon_target)+1);
lon = double(lon_tmp(lonind));
lat_tmp = ncread(file, 'latitude');
latind = find(lat_tmp > min(lat_target)-1 & lat_tmp < max(lat_target)+1);
lat = double(lat_tmp(latind));

vari = ncread(file, vari_str, [lonind(1) latind(1) tindex(1)], [length(lonind) length(latind), length(tindex)]);
vari = mean(vari, 3);

disp(['Loading CFSv2 ', vari_str, ' in ', ystr, mstr])

end