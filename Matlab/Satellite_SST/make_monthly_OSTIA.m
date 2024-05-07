%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make OSTIA monthly SST using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2018:2018;
month_avg = [1:12];
filename_header = 'OSTIA_';
filename_footer = '';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');

        filepath_all = ['/data/jungjih/Observations/Satellite_SST/OSTIA/daily/', ystr, '/', mstr, '/'];
        filenames = dir([filepath_all, '*.nc']);
        for fi = 1:length(filenames)
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