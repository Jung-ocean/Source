%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CEC climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
filename_header = 'SMOS_L3_DEBIAS_LOCEAN_AD_climatology_';
filename_footer = '_EASE_09d_25km_v08';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    command = ['find ', filepath_monthly, ' -name *', mstr,'_* | xargs -I {} ln -s {} .'];
    system(command)

    command = ['ncea ', ['*', mstr, '_*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['find . ! -name ''*climatology*'' | xargs -I {} rm -f {}'];
    system(command)
end