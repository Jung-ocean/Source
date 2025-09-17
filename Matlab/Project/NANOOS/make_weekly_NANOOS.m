%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make weekly averaged using daily NANOOS output
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

datenum_weekly = datenum(2023,1,5):4:datenum(2024,12,25);

filepath = '/data/jungjih/Models/NANOOS/daily/';

for wi = 1:length(datenum_weekly)
    datenum_center = datenum_weekly(wi);
    datenum_target = datenum_center-3:datenum_center+3;

    filenames = [];
    for di = 1:length(datenum_target)
        datenum_tmp = datenum_target(di);
        yyyymmdd = datestr(datenum_tmp, 'yyyymmdd');

        filename = ['NANOOS_', yyyymmdd, '.nc'];
        file = [filepath, filename];

        command = ['ln -s ', file, ' ./'];
        system(command)
        filenames = [filenames, filename, ' '];
    end
    command = ['ncra ', filenames, ' ./NANOOS_weekly_', datestr(datenum_center, 'yyyymmdd'), '.nc'];
    system(command)

    command = ['find . ! -name "*weekly*" | xargs -I {} rm -f {}'];
    system(command)
end