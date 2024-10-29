%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CEC SMOS winter and summer average
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2011:2023;
month_avg = [1:3];

di = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    for mi = 1:length(month_avg)
        di = di + 1;
        mm = month_avg(mi); mstr = num2str(mm, '%02i');
        filename = ['SMOS_L3_DEBIAS_LOCEAN_AD_', ystr, mstr, '_EASE_09d_25km_v09.nc'];

        data(di,:,:) = ncread(filename, 'SSS');
%         figure; pcolor(squeeze(data(di,:,:))); shading flat
    end
end

data_mean = squeeze(nanmean(data,1));

file_out = 'SMOS_L3_DEBIAS_LOCEAN_AD_winter_EASE_09d_25km_v09.nc';
ncwrite(file_out, 'SSS', data_mean)