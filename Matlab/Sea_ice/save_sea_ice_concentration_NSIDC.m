%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sea ice concentration with velocity using geotiff file from NSIDC
%
% Geotiff file info
% sea ice concentration 0-1000 (divide by 10 to get percent)
% ocean 0
% pole hole 2510
% coast line 2530
% land 2540
% missing 2550
% Table 5 (https://nsidc.org/sites/default/files/g02135-v003-userguide_1_1.pdf)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2018:2022;
mm_all = 1:12;

filepath_con = '/data/jungjih/Observations/Sea_ice/NSIDC/concentration/daily/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    aice = NaN(yeardays(yyyy), 448, 304);
    timenum = [];
    ti = 1;
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(di, '%02i');

            tiffile = [filepath_con, 'N_', ystr, mstr, dstr, '_concentration_v3.0.tif'];

            [Z,R] = readgeoraster(tiffile,"OutputType","double");
            Z(Z == 2530) = NaN;
            Z(Z == 2540) = NaN;
            [X,Y] = worldGrid(R);

            info = geotiffinfo(tiffile);
            [lat,lon] = projinv(info,X,Y);

            timenum(ti) = datenum(yyyy,mm,dd);
            aice(ti,:,:) = Z/10/100;

            ti = ti + 1;
            disp([ystr, mstr, dstr])
        end
    end

    save(['aice_NSIDC_', ystr, '.mat'], 'lat', 'lon', 'timenum', 'aice');
end

% figure; hold on; grid on
% plot_map('Gulf_of_Anadyr', 'mercator', 'l')
% p = pcolorm(lat, lon, Z/10/100);
% caxis([0 1])
% uistack(p, 'bottom')