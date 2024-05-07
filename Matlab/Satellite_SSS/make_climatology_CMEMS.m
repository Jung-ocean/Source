%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
year_start = [2019 2019 2019 2019 2019 2019 2018 2018 2018 2018 2018 2018];
year_end = year_start+3;
filename_header = 'dataset-sss-ssd-rep-climatology_';
filename_footer = '';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/CMEMS/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    for yi = year_start(mi):year_end(mi)
        ystr = num2str(yi);
        command = ['find ', filepath_monthly, ' -name *', ystr, mstr,'15T1200Z* | xargs -I {} ln -s {} .'];
        system(command)
    end

    command = ['ncea ', ['*monthly*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['*monthly*']];
    system(command)
end