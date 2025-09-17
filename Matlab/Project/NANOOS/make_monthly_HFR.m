%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make monthly averaged using daily HFR daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2023:2024;
mm_all = 1:12;

filepath = '/data/jungjih/Observations/HFR/daily/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        files = dir([filepath, '*', ystr, mstr, '*']);
        filenames = [];
        if length(files) == eomday(yyyy,mm)
            for fi = 1:length(files)
                file_tmp = [files(fi).folder, '/', files(fi).name];
                command = ['ln -s ', file_tmp, ' ./'];
                system(command)
                filenames = [filenames, files(fi).name, ' '];
            end
            command = ['ncra ', filenames, ' ./HFR_monthly_', ystr, mstr, '.nc'];
            system(command)

            command = ['find . ! -name "*monthly*" | xargs -I {} rm -f {}'];
            system(command)
        end
    end
end