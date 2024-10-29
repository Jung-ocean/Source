%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate and save sea ice concentration using ASI data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2012:2023;
mm_all = 1:7;

region = 'Gulf_of_Anadyr';

filepath_monthly = '/data/jungjih/Observations/Sea_ice/ASI/monthly_ROMSgrid/';

g = grd('BSf');
[mask, area] = mask_and_area(region, g);

Fi = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        file = [filepath_monthly, 'asi-AMSR2-n6250-', ystr, mstr, '-v5.4.nc'];

        if exist(file) == 0
            Fi = [Fi; NaN];
            continue
        end

        lon = ncread(file, 'longitude')';
        lat = ncread(file, 'latitude')';
        sic = ncread(file, 'z')';
        
        Fi_tmp = sum(sic(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
        Fi = [Fi; Fi_tmp];

        disp([ystr, mstr])
    end % mi
end % yi
Fi = Fi/100;

figure; hold on; grid on;
plot(timenum, Fi, '-o')
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy')

if length(mm_all) == 1
    output_filename = ['Fi_ASI_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['Fi_ASI_', region, '.mat'];
end
save(output_filename, 'timenum', 'Fi')