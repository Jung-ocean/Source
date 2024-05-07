%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make RSS climatology SSS using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
year_start = [2019 2019 2019 2019 2019 2019 2018 2018 2018 2018 2018 2018];
year_end = year_start+3;
filename_header = 'RSS_smap_SSS_L3_climatology_';
filename_footer = '_FNL_v05.3';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v5.3/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    for yi = year_start(mi):year_end(mi)
        ystr = num2str(yi);
        command = ['find ', filepath_monthly, ' -name *_monthly_', ystr , '_', mstr,'_* | xargs -I {} ln -s {} .'];
        system(command)
    end

    command = ['ncea ', ['*monthly*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['*monthly*']];
    system(command)
end