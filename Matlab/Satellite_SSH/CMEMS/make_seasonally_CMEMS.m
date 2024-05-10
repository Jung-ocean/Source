%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS seasonally SSH using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 1993:2022;
month_avg = [1:12];
filename_header = 'dt_global_allsat_phy_l4_';
filename_footer = '';

month_all = {'JFM', 'AMJ', 'JAS', 'OND'};

JFM = 1:3;
AMJ = 4:6;
JAS = 7:9;
OND = 10:12;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(month_all)
        month_str = month_all{mi};
        month = eval(month_str);

        filepath_all = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/'];
        for mmi = 1:length(month)
            mstr = num2str(month(mmi), '%02i');
            filename = [filename_header, ystr, mstr, '.nc'];
            command = ['ln -s ', filepath_all, filename, ' ./tmp_', filename];
            system(command)
        end
        command = ['ncea *tmp* ', filename_header, ystr, '_', month_str, filename_footer '.nc'];
        system(command)
        
        command = ['rm -f *tmp*'];
        system(command)
    end
end