% .grib to .nc using wgrib2.exe
clear; clc

filename = '12-2';

infile = [filename, '.grib'];
outfile = [filename, '.nc'];

[status,result] = ... 
    system(['"F:\��ġ��&��ġ��\wgrib2\wgrib2.exe" ' '"' infile '"' ' -netcdf' ' "' outfile '"']); 