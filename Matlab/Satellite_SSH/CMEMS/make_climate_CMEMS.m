%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CMEMS climate SSH using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
year_start = [2019 2019 2019 2019 2019 2019 2018 2018 2018 2018 2018 2018];
year_end = year_start+3;
filename_header = 'dt_global_allsat_phy_l4_climate_';
filename_footer = '';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    for yi = year_start(mi):year_end(mi)
        ystr = num2str(yi);
        filename = dir([filepath_monthly, '*', ystr, mstr, '*']);
        command = ['ln -s ', filepath_monthly, filename.name, ' ./tmp_', filename.name];
        system(command)
    end

    command = ['ncea ', ['tmp*'], ' ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['rm -f ', ['tmp*']];
    system(command)
end