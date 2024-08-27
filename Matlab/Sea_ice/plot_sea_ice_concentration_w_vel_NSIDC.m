%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot sea ice concentration with velocity from NSIDC
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2022; 
mm_all = 1:2;

region = 'Gulf_of_Anadyr';

ystr = num2str(yyyy);
filepath_concentration = ['/data/jungjih/Observations/Sea_ice/NSIDC/'];
filename_concentration = ['aice_NSIDC_', ystr, '.mat'];
file_concentration = [filepath_concentration, filename_concentration];
load(file_concentration)

filepath_vel = ['/data/smithj28/Obersvations/NSIDC_Ice_Motion/'];
filename_vel = ['icemotion_daily_nh_25km_', ystr, '0101_', ystr, '1231_v4.1.nc'];
file_vel = [filepath_vel, filename_vel];

lon_vel = double(ncread(file_vel, 'longitude'));
lat_vel = double(ncread(file_vel, 'latitude'));
u = ncread(file_vel, 'u');
v = ncread(file_vel, 'v');

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Gulf_of_Anadyr', 'mercator', 'l');

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        YTD = datenum(yyyy,mm,dd) - datenum(yyyy,1,1) + 1;

        aice_day = squeeze(aice(YTD,:,:));

        u_day = double(squeeze(u(:,:,YTD)));
        v_day = double(squeeze(v(:,:,YTD)));

        ugeo = [cosd(lon_vel).*u_day + sind(lon_vel).*v_day];
        vgeo = [-sind(lon_vel).*u_day + cosd(lon_vel).*v_day];

        p = pcolorm(lat, lon, aice_day);
        uistack(p, 'bottom');
        caxis([0 1]);
        c = colorbar;

        scale = 0.1;
        q = quiverm(lat_vel, lon_vel, vgeo.*scale, ugeo.*scale, 0);
        q(1).Color = 'k';
        q(2).Color = 'k';

        qref = quiverm(66, -184, 0, 10*scale, 0);
        qref(1).Color = 'k';
        qref(2).Color = 'k';
        qt = textm(65.7, -184, '10 cm/s');

        title(datestr(datenum(yyyy,mm,dd), 'mmm dd, yyyy'))

        print(['concentration_w_vel_NSIDC_', datestr(datenum(yyyy,mm,dd), 'yyyymmdd')], '-dpng');

        delete(p)
        delete(q)
    end
end
