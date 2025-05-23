%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make CEC SSS std using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [1:12];
% year_start = [2019 2019 2019 2019 2019 2019 2018 2018 2018 2018 2018 2018];
% year_end = year_start+3;
year_start = 2015.*ones(1,12);
year_end = year_start+8;
filename_header = 'SMOS_L3_DEBIAS_LOCEAN_AD_std_';
filename_footer = '_EASE_09d_25km_v09';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    for yi = year_start(mi):year_end(mi)
        ystr = num2str(yi);
        command = ['find ', filepath_monthly, ' -name *', ystr, mstr,'_* | xargs -I {} ln -s {} .'];
        system(command)
    end

    command = ['ncecat ', ['*', mstr, '_*'], ' ./cat.nc'];
    system(command)

    command = ['ncea ', ['*', mstr, '_*'], ' ./mean.nc'];
    system(command)

    command = ['ncbo -v SSS cat.nc mean.nc deviation.nc'];
    system(command)

    command = ['ncra -y rmssdn deviation.nc ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['find . ! -name ''*std*'' | xargs -I {} rm -f {}'];
    system(command)
end