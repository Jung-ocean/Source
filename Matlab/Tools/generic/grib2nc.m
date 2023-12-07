% .grib to .nc using wgrib2.exe
clear; clc

filename = '12-2';

infile = [filename, '.grib'];
outfile = [filename, '.nc'];

[status,result] = ... 
    system(['"F:\설치류&비설치류\wgrib2\wgrib2.exe" ' '"' infile '"' ' -netcdf' ' "' outfile '"']); 