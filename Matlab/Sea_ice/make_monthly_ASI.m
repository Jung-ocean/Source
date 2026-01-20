%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ASI monthly using daily files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2025:2025;
mm_all = [6:6];
filename_header = 'asi-AMSR2-n6250-';
filename_footer = '-v5.4';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    filepath_all = ['/data/jungjih/Observations/Sea_ice/ASI/AMSR2/daily_polar/'];

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');
        files = dir([filepath_all, '*-', ystr, mstr, '*.nc']);

        filenames = [];
        for fi = 1:length(files)
            filename = files(fi).name;
            command = ['ln -s ', filepath_all, filename, ' ./', filename];
            system(command)
            filenames{fi} = [filename, ' '];
        end

        if length(files) == eomday(yyyy,mm)
            if strcmp([ystr,mstr], '201604')
                command = ['rm -f *20160415*'];
                system(command)
            elseif strcmp([ystr,mstr], '201903')
                command = ['rm -f *20190318*'];
                system(command)
            elseif strcmp([ystr,mstr], '202203')
                command = ['rm -f *20220302* *20220309* *20220317* *20220320*'];
                system(command)
            elseif strcmp([ystr,mstr], '201206')
                command = ['rm -f *20120613*'];
                system(command)
                command = ['rm -f *20120616*'];
                system(command)
                command = ['rm -f *20120621*'];
                system(command)
                index = find(contains(filenames, '20120613') | contains(filenames, '20120616') | contains(filenames, '20120621'));
                filenames(index) = [];
            end
            filenames = append(filenames{:});
            command = ['ncea ', filenames, ' ', filename_header, ystr, mstr, filename_footer '.nc'];
            system(command)
        end
        command = ['rm -f ', filenames];
        system(command)
    end
end