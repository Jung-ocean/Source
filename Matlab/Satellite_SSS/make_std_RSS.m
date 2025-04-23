%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Make RSS SSS std using monthly files
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

month_avg = [4:12];
% year_start = [2019 2019 2019 2019 2019 2019 2018 2018 2018 2018 2018 2018];
% year_end = year_start+3;
year_start = 2015.*ones(1,12);
year_end = year_start+8;
filename_header = 'RSS_smap_SSS_L3_std_';
filename_footer = '_FNL_v06.0';

filepath_monthly = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/monthly/'];

for mi = 1:length(month_avg)
    mm = month_avg(mi); mstr = num2str(mm, '%02i');

    for yi = year_start(mi):year_end(mi)
        ystr = num2str(yi);
        command = ['find ', filepath_monthly, ' -name *_monthly_', ystr , '_', mstr,'_* | xargs -I {} ln -s {} .'];
        system(command)
    end

    command = ['ncecat ', ['*', mstr, '_*'], ' ./cat.nc'];
    system(command)

    command = ['ncea ', ['*', mstr, '_*'], ' ./mean.nc'];
    system(command)

    command = ['ncbo -v sss_smap cat.nc mean.nc deviation.nc'];
    system(command)

    command = ['ncra -y rmssdn deviation.nc ', filename_header, mstr, filename_footer, '.nc'];
    system(command)

    command = ['find . ! -name ''*std*'' | xargs -I {} rm -f {}'];
    system(command)
end