%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
filename_header = 'dataset-sss-ssd-rep-climatology_';
filename_footer = '_P20231007T0000Z';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    command = ['find ', filepath_monthly, ' -name *', mstr,'15T1200Z* | xargs -I {} ln -s {} .'];
    system(command)

    command = ['ncea ', ['*monthly*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['*monthly*']];
    system(command)
end