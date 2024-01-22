%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make OISSS monthly SSS using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2022:2022;
month_avg = [1:9];
filename_header = 'OISSS_L4_multimission_global_7d_v2.0_';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_daily = ['/data/sdurski/Observations/Satellite_SSS/OISSS_v2/'];

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenames = dir([filepath_daily, '*', ystr, '-', mstr, '*']);
        for fi = 1:length(filenames)
            filename = filenames(fi).name;
            command = ['ln -s ', filepath_daily, filename, ' ./'];
            system(command)
        end
        command = ['ncea ', ['*', mstr, '-*'], ' ', filename_header, ystr, mstr, '.nc'];
        system(command)
        
        command = ['rm -f ', ['*', mstr, '-*']];
        system(command)
    end
end