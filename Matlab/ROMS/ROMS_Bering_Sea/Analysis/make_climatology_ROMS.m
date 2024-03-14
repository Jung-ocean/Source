%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make ROMS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
filename_header = 'Dsm_1rnoff_climatology_';
filename_footer = '';

filepath_monthly = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm1_rnoff/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    command = ['find ', filepath_monthly, ' -name *', mstr,'.nc | xargs -I {} ln -s {} .'];
    system(command)

    command = ['ncea ', ['*', mstr, '.nc'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['find . ! -name ''*climatology*'' | xargs -I {} rm -f {}'];
    system(command)
end