%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save model files and timenum for averaging
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2022:2025;

filepath = '/data/jungjih/Models/WCOFS/';
datestr_type = 'yyyymmdd';
reftime = datenum(2016,1,1);

files = [];
timenum = [];
i = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    filenames = dir([filepath, ystr, '/', '*', ystr, '*.nc']);

    for fi = 1:length(filenames)
        i = i+1;
        file = [filenames(fi).folder, '/', filenames(fi).name];
        ot = ncread(file, 'ocean_time');

        files{i} = file;
        timenum(i) = ot/60/60/24 + reftime;

        disp(datestr(timenum(i), 'yyyymmdd HH:MM...'))
    end
end

save(['files_and_timenum_WCOFS', '.mat'], 'files', 'timenum')