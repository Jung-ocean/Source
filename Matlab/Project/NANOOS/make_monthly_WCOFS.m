%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make monthly averaged using daily WCOFS output
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2024:2024;
mm_all = 1:12;

filepath = '/data/jungjih/Models/WCOFS/daily_3D/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filenames = [];
        filenum = 0;
        for di = 1:eomday(yyyy,mm)
            dd = di;
            timenum_tmp = datenum(yyyy,mm,dd)+1; % +1 because of the difference between filename and ocean_time
            yyyymmdd = datestr(timenum_tmp, 'yyyymmdd');

            fileinfo = dir([filepath, '*', yyyymmdd, '*']);
            file_tmp = [fileinfo.folder, '/', fileinfo.name];
            if exist(file_tmp)
                filenum = filenum + 1;
                command = ['ln -s ', file_tmp, ' ./'];
                system(command)
                filenames = [filenames, fileinfo.name, ' '];
            end
        end

        if filenum == eomday(yyyy,mm)
            command = ['ncra ', filenames, ' ./WCOFS_monthly_', ystr, mstr, '.nc'];
            system(command)

            command = ['find . ! -name "*monthly*" | xargs -I {} rm -f {}'];
            system(command)
        end
    end
end