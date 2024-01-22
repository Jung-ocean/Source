%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make JPL SMAP monthly SSS using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2020:2020; % 201906, 201907, 202004, 202005, 202006 missing; 202012 discontinuity
month_avg = [12:12];
filename_header = 'smap_l3_sss_v5p0_';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_daily = ['/data/sdurski/Observations/Satellite_SSS/BS/JPL/', ystr, '/'];

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenames = dir([filepath_daily, '*', ystr, mstr, '*']);
        for fi = 1:length(filenames);
            filename = filenames(fi).name;
            command = ['ln -s ', filepath_daily, filename, ' ./'];
            system(command)
        end
        command = ['ncea *8days* ', filename_header, ystr, mstr, '.nc'];
        system(command)
        
        command = ['rm -f *8days*'];
        system(command)
    end
end