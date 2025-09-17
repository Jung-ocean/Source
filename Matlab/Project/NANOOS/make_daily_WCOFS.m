%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make daily averaged using hourly WCOFS output
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

load('/data/jungjih/Models/WCOFS/files_and_timenum_WCOFS.mat');

yyyy_all = 2023:2024;
datenum_start = datenum(yyyy_all(1),1,1);
datenum_end = datenum(yyyy_all(end),12,31);

for di = datenum_start:datenum_end
    datenum_target = di;
    dstr = datestr(datenum_target, 'yyyymmdd');
    index = find(timenum > datenum_target & timenum < datenum_target+1);
    if length(index) == 23
        for fi = 1:length(index)
            command = ['ln -s ', files{index(fi)}, ' ./'];
            system(command)
        end
            command = ['ncra *n0* ./WCOFS_2D_', dstr, '.nc'];
            system(command)
            command = ['rm -f *n0*'];
            system(command)
    else
        asdf
    end
end