%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make RSS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
filename_header = 'RSS_smap_SSS_L3_climatology_';
filename_footer = '_FNL_v05.3';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    command = ['find ', filepath_monthly, ' -name *_', mstr,'_* | xargs -I {} ln -s {} .'];
    system(command)

    command = ['ncea ', ['*monthly*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['*monthly*']];
    system(command)
end