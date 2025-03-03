%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ADT (MSS + SSHA - geoid) from ICESat2 ATL21
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 2:2;

g = grd('BSf');

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/ATL21/data/';

ystr = num2str(yyyy);

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')
colormap jet
caxis([-10 50])
c = colorbar;
c.Title.String = 'cm';

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename = dir([filepath, 'ATL21-01_', ystr, mstr, '*']);
    filename = filename.name;
    file = [filepath, filename];

    lat = h5read(file, '/grid_lat')';
    lon = h5read(file, '/grid_lon')';
    grid_x = h5read(file, '/grid_x')';
    grid_y = h5read(file, '/grid_y')';

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        ssha = h5read(file, ['/daily/day', dstr, '/mean_ssha'])';
        fv = h5readatt(file, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
        ssha(ssha == fv) = NaN;
        mss = h5read(file, ['/daily/day', dstr, '/mean_weighted_mss'])';
        fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
        mss(mss == fv) = NaN;
        geoid = h5read(file, ['/daily/day', dstr, '/mean_weighted_geoid'])';
        fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
        geoid(geoid == fv) = NaN;
      
        ADT = mss + ssha - geoid;

        p = scatterm(lat(:),lon(:),5,ADT(:)*100,'o');
    end
end
ddd
timenum_start = datenum(yyyy,mm,1);
timenum_end = datenum(yyyy,mm,dd);

title([datestr(timenum_start, 'mmm dd'), ' - ', datestr(timenum_end, 'mmm dd, yyyy')])

print(['ADT_ICESat2_ATL21_', datestr(timenum_end, 'yyyymm')], '-dpng')

% save(['ADT_ICESat2_', ystr, '.mat'], 'data_ICESat2')