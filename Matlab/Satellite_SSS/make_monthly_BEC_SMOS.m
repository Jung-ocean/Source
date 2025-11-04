%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make BEC SMOS monthly SSS using 4-day interval files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2011:2022;
month_avg = [1:12];
filename_header = 'BEC_SSS___SMOS__ARC_L3__B_';
filename_footer = '_25km__9d_REP_v4.0';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    filepath_all = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v4/9day/'];
    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        files = dir([filepath_all, ystr, '/*', ystr, mstr, '*']);
        if isempty(files)
            continue
        end
        filenames = [];
        for fi = 1:length(files)
            filename = files(fi).name;
            command = ['ln -s ', filepath_all, ystr, '/', filename, ' ./'];
            system(command)
            filenames = [filenames, files(fi).name, ' '];
        end
        command = ['ncea ', filenames, ' ', filename_header, ystr, mstr, filename_footer '.nc'];
        system(command)
        
        command = ['rm -f ', filenames];
        system(command)
    end
end