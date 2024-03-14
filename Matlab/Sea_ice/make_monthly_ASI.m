%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ASI monthly using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2022:2022;
month_avg = [3:3];
filename_header = 'asi-AMSR2-n6250-';
filename_footer = '-v5.4';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_all = ['/data/jungjih/Observations/Sea_ice/ASI/daily/'];

    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenames = dir([filepath_all, '*-', ystr, mstr, '*']);
        for fi = 1:length(filenames);
            filename = filenames(fi).name;
            command = ['ln -s ', filepath_all, filename, ' ./tmp_', filename];
            system(command)
        end
                
        command = ['ls *tmp* | wc -l'];
        [status, nfile] = system(command);
        if str2num(nfile) == eomday(yyyy,mm)
            
            if strcmp([ystr,mstr], '201604')
                command = ['rm -f *20160415*'];
            elseif strcmp([ystr,mstr], '201903')
                command = ['rm -f *20190318*'];
            elseif strcmp([ystr,mstr], '202203')
                command = ['rm -f *20220302* *20220309* *20220317* *20220320*'];
            end
            system(command)
        
            command = ['ncea *tmp* ', filename_header, ystr, mstr, filename_footer '.nc'];
            system(command)

        end

        command = ['rm -f *tmp*'];
        system(command)
    end
end