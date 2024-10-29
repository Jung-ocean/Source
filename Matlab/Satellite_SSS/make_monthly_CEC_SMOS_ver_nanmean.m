%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CEC SMOS monthly SSS using 4-day interval files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2010:2010;
month_avg = [2:2];
filename_header = 'SMOS_L3_DEBIAS_LOCEAN_AD_';
filename_footer = '_EASE_09d_25km_v09';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_all = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/4day/'];

    eomdays = eomday(yyyy,1:12);
    
    for mi = 1:length(month_avg)
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filenames = dir([filepath_all, '*', ystr, mstr, '*']);
        for fi = 1:length(filenames);
            filename = filenames(fi).name;
            file = [filepath_all, filename];
            data(fi,:,:) = ncread(file, 'SSS');
        end
        
        data_mean = squeeze(nanmean(data,1));

        file_out = [filename_header, ystr, mstr, filename_footer '.nc'];
        ncwrite(file_out, 'SSS', data_mean)
    end
end