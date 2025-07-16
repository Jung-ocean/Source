%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS monthly SSH using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2023:2024;
month_avg = [1:12];
filename_header = 'dt_global_allsat_phy_l4';
filename_footer = '';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(month_avg)
        mm = month_avg(mi);
        mstr = num2str(mm, '%02i');

        filepath = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/daily/', ystr, '/', mstr, '/'];
        files = dir([filepath, '*.nc']);
        filenames = [];
        if length(files) == eomday(yyyy,mm)
            for fi = 1:length(files)
                filename = files(fi).name;
                command = ['ln -s ', filepath, filename, ' ./'];
                system(command)
                filenames = [filenames, files(fi).name, ' '];
            end
            command = ['ncea ', filenames, ' ', filename_header, '_monthly_', ystr, mstr, filename_footer '.nc'];
            system(command)

            command = ['rm -f ', filenames];
            system(command)
        end
    end
end