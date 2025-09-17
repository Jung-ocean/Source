%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate and save sea ice concentration using ASI data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2012:2024;
mm_all = 1:12;

region = 'Koryak_coast';

filepath_daily = '/data/jungjih/Observations/Sea_ice/ASI/daily_ROMSgrid/';

g = grd('BSf');
[mask, area] = mask_and_area(region, g);

Fi = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            timenum = [timenum; datenum(yyyy,mm,dd)];

            file = [filepath_daily, 'asi-AMSR2-n6250-', ystr, mstr, dstr, '-v5.4.nc'];

            if exist(file) == 0
                Fi = [Fi; NaN];
                continue
            end

            lon = ncread(file, 'longitude');
            lat = ncread(file, 'latitude');
            sic = ncread(file, 'z');

            Fi_tmp = sum(sic(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
            Fi = [Fi; Fi_tmp];

            disp([ystr, mstr, dstr])
        end % di
    end % mi
end % yi
Fi = Fi/100;

output_filename = ['Fi_ASI_', region, '_daily.mat'];

figure; hold on; grid on;
plot(timenum, Fi, '-k')
xticks(datenum(yyyy_all,1,1));
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')

ddd
save(output_filename, 'timenum', 'Fi')