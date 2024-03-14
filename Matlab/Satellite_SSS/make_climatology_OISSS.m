%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make OISSS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
filename_header = 'OISSS_L4_multimission_global_7d_v2.0_climatology_';
filename_footer = '';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/OISSS_v2/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    command = ['find ', filepath_monthly, ' -name *', mstr,'.nc | xargs -I {} ln -s {}'];
    system(command)

    command = ['ncea ', ['*', mstr, '.nc'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['find . ! -name ''*climatology*'' | xargs -I {} rm -f {}'];
    system(command)
end