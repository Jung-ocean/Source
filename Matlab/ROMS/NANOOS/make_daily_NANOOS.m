%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make daily averaged using hourly NANOOS output
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2023:2024;
datenum_start = datenum(yyyy_all(1),1,1);
datenum_end = datenum(yyyy_all(end),12,31);

filepath = '/home/server/ftp/dist/tides/ingria/ORWA/';

for di = datenum_start:datenum_end
    datenum_target = di;
    dstr = datestr(datenum_target, 'dd-mmm-yyyy');
    dstr_output = datestr(datenum_target, 'yyyymmdd');

    file_tmp = dir([filepath, '*', dstr, '*']);
    file = [file_tmp.folder, '/', file_tmp.name];

    command = ['ncra ', file, ' ./NANOOS_', dstr_output, '.nc'];
    system(command)
end