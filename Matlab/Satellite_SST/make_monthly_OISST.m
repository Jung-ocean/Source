%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make OISST monthly SST using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2023:2024;
month_avg = [1:12];
filename_header = 'OISST_';
filename_footer = '';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); 
    ystr = num2str(yyyy);

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); 
        mstr = num2str(mm, '%02i');

        filepath_all = ['/data/jungjih/Observations/Satellite_SST/OISST/daily/'];
        filenames = dir([filepath_all, '*', ystr, mstr, '*.nc']);
        if length(filenames) == eomday(yyyy,mm)
            for fi = 1:length(filenames)
                filename = filenames(fi).name;
                command = ['ln -s ', filepath_all, filename, ' ./tmp_', filename];
                system(command)
            end
            command = ['ncra *tmp* ', filename_header, '_monthly_' ystr, mstr, filename_footer '.nc'];
            system(command)

            command = ['rm -f *tmp*'];
            system(command)
        end
    end
end