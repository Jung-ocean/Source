%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make monthly averaged using daily HFR daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2024:2024;
mm_all = 1:12;

filepath = '/data/jungjih/Observations/Surface_current/HFR/daily/';
filepath_monthly = '/data/jungjih/Observations/Surface_current/HFR/monthly/';
cd(filepath_monthly)

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        files = dir([filepath, '*', ystr, mstr, '*']);
        filenames = [];
        u_mask = 1;
        v_mask = 1;
        if length(files) == eomday(yyyy,mm)
            for fi = 1:length(files)
                file_tmp = [files(fi).folder, '/', files(fi).name];
                command = ['ln -s ', file_tmp, ' ./'];
                system(command)
                filenames = [filenames, files(fi).name, ' '];

                u_tmp = ncread(file_tmp, 'u_mean');
                u_mask_tmp = u_tmp./u_tmp;
                u_mask = u_mask.*u_mask_tmp;
                v_tmp = ncread(file_tmp, 'v_mean');
                v_mask_tmp = v_tmp./v_tmp;
                v_mask = v_mask.*v_mask_tmp;
            end
            filename_out = ['HFR_monthly_', ystr, mstr, '.nc'];
            command = ['ncra ', filenames, ' ./', filename_out];
            system(command)
            
            u_mean = ncread(filename_out, 'u_mean');
            ncwrite(filename_out, 'u_mean', u_mean.*u_mask);
            v_mean = ncread(filename_out, 'v_mean');
            ncwrite(filename_out, 'v_mean', v_mean.*v_mask);

            command = ['find . ! -name "*monthly*" | xargs -I {} rm -f {}'];
            system(command)
        end
    end
end