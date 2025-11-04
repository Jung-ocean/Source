%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

yyyy_all = 2015:2023;
month_avg = [1:12];
filename_header = 'dataset-sss-ssd-rep-climate_';
filename_footer = '';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/CMEMS/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); 
    mstr = num2str(mm, '%02i');

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi);
        ystr = num2str(yyyy);
        command = ['find ', filepath_monthly, ' -name *', ystr, mstr,'15T1200Z* | xargs -I {} ln -s {} .'];
        system(command)
    end

    command = ['ncea ', ['*monthly*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['*monthly*']];
    system(command)
end