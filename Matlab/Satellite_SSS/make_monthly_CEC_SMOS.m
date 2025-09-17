%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CEC SMOS monthly SSS using 4-day interval files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2010:2024;
month_avg = [1:12];
filename_header = 'SMOS_L3_DEBIAS_LOCEAN_AD_';
filename_footer = '_EASE_09d_25km_v10';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_all = ['/data/jungjih/Observations/Satellite_SSS/CEC/v10/4day/'];

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenames = dir([filepath_all, '*', ystr, mstr, '*']);
        for fi = 1:length(filenames);
            filename = filenames(fi).name;
            command = ['ln -s ', filepath_all, filename, ' ./tmp_', filename];
            system(command)
        end
        command = ['ncea *tmp* ', filename_header, ystr, mstr, filename_footer '.nc'];
        system(command)
        
        command = ['rm -f *tmp*'];
        system(command)
    end
end