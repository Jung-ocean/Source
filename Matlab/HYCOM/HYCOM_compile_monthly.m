%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Compile various HYCOM monthly data as a one NetCDF file
%       You need a 'create_HYCOM_nc.m' file
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filepath = '.\';
yyyy = 2017; % target year

for mi = 1:12
mm = mi; % target month

head = ['912_archMN.', num2str(yyyy), '_', num2char(mm,2), '_'];

lon_lim = [400:2000]; % Longitude limits
lat_lim = [1400:2600]; % Latitude limits

% Output file name
compiled_ncname = ['HYCOM_', num2str(yyyy), num2char(mm,2), '.nc'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tfilename = [head, '3zt.nc']; tfile = [filepath, tfilename];
sfilename = [head, '3zs.nc']; sfile = [filepath, sfilename];
ufilename = [head, '3zu.nc']; ufile = [filepath, ufilename];
vfilename = [head, '3zv.nc']; vfile = [filepath, vfilename];
sshfilename = [head, 'bot.nc']; sshfile = [filepath, sshfilename];

disp('File list')
disp(tfilename); disp(sfilename);
disp(ufilename); disp(vfilename); disp(sshfilename)
disp(' ')
disp(['Output file is ', compiled_ncname])
disp(' ')

tnc = netcdf(tfile);
ftime = tnc{'MT'}(:);
fdate = tnc{'Date'}(:);
depth = tnc{'Depth'}(:); len_depth = length(depth);
latitude = tnc{'Latitude'}(:);
longitude = tnc{'Longitude'}(:);
close(tnc)

lon_re = longitude(lat_lim, lon_lim);
lat_re = latitude(lat_lim, lon_lim);

if size(lat_re) == size(lon_re)
    size_2d = size(lat_re);
end
size_3d = [len_depth size_2d];

% Temperature
disp('Temperature...')
tnc = netcdf(tfile); 
temp = tnc{'pot_temp'}(:, :, lat_lim, lon_lim);
close(tnc);

% Domain check
figure; pcolor(lon_re, lat_re, squeeze(temp(1,:,:))); shading flat
title('Selected Domain')

% Salinity
disp('Salinity...')
snc = netcdf(sfile); 
salt = snc{'salinity'}(:, :, lat_lim, lon_lim);
close(snc);

% U
disp('U...')
unc = netcdf(ufile); 
u = unc{'u'}(:, :, lat_lim, lon_lim);
close(unc);

% V
disp('V...')
vnc = netcdf(vfile); 
v = vnc{'v'}(:, :, lat_lim, lon_lim);
close(vnc);

% SSH
disp('SSH...')
sshnc = netcdf(sshfile); 
ssh = sshnc{'ssh'}(:, lat_lim, lon_lim);
close(sshnc);

create_HYCOM_nc(compiled_ncname, size_3d)

nc = netcdf(compiled_ncname, 'w');
nc{'longitude'}(:) = lon_re; nc{'latitude'}(:) = lat_re;
nc{'depth'}(:) = depth; nc{'time'}(:) = ftime; nc{'ssh'}(:) = ssh;
nc{'temp'}(:) = temp; nc{'salt'}(:) = salt; nc{'u'}(:) = u; nc{'v'}(:) = v;
close(nc)

end