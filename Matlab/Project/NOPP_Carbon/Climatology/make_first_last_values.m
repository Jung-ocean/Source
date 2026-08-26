clear; clc

domain = 'Oregon_1km_large';
model = 'LiveOcean';
yyyy = 2024;

filename = ['climate_', domain, '_', model, '_202401.nc'];
filename_first = ['climate_', domain, '_', model, '_first.nc'];
command = ['ncks -d temp_time,0,0 -d salt_time,0,0 ', ...
    filename, ' ./', filename_first];
system(command)
ncwrite(filename_first, 'temp_time', 0);
ncwrite(filename_first, 'salt_time', 0);

filename = ['climate_', domain, '_', model, '_202412.nc'];
filename_last = ['climate_', domain, '_', model, '_last.nc'];
% command = ['ncks -d temp_time,11,11 -d salt_time,11,11 ', ...
command = ['ncks -d temp_time,30,30 -d salt_time,30,30 ', ...
    filename, ' ./', filename_last];
system(command)
ncwrite(filename_last, 'temp_time', yeardays(yyyy));
ncwrite(filename_last, 'salt_time', yeardays(yyyy));