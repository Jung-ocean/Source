%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compare ROMS zeta to DOT (SSH-geoid) from ICESat2 ATL21
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 2:2;

exp = 'Dsm4';
startdate = datenum(2018,7,1);
g = grd('BSf');
lat = g.lat_rho;
lon = g.lon_rho;

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

filepath_sat = '/data/jungjih/Observations/Sea_ice/ICESat2/ATL21/data/';

ystr = num2str(yyyy);

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,2);
nexttile(1); hold on;
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')
colormap jet
caxis([-10 50])
c = colorbar;
c.Title.String = 'cm';
title('ICESat-2 L3B')
nexttile(2); hold on;
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')
colormap jet
caxis([-30 30])
c = colorbar;
c.Title.String = 'cm';
title('ROMS')

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename_sat = dir([filepath_sat, 'ATL21-01_', ystr, mstr, '*']);
    filename_sat = filename_sat.name;
    file_sat = [filepath_sat, filename_sat];

    lat_sat = h5read(file_sat, '/grid_lat')';
    lon_sat = h5read(file_sat, '/grid_lon')';
    grid_x = h5read(file_sat, '/grid_x')';
    grid_y = h5read(file_sat, '/grid_y')';

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');
        timenum = datenum(yyyy,mm,dd);
        filenum = timenum - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = [exp, '_avg_', fstr, '.nc'];
        file = [filepath, filename];
        zeta = ncread(file, 'zeta')';

        try
        ssha = h5read(file_sat, ['/daily/day', dstr, '/mean_ssha'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
        ssha(ssha == fv) = NaN;
        mss = h5read(file_sat, ['/daily/day', dstr, '/mean_weighted_mss'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
        mss(mss == fv) = NaN;
        geoid = h5read(file_sat, ['/daily/day', dstr, '/mean_weighted_geoid'])';
        fv = h5readatt(file_sat, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
        geoid(geoid == fv) = NaN;

        ADT = mss + ssha - geoid;
        catch
            continue
        end
                      
        nexttile(1);
        psat = scatterm(lat_sat(:),lon_sat(:),20,ADT(:)*100,'o', 'Filled');

        nexttile(2);
        index = find(isnan(ADT) ~= 1);
        lat_interp = lat_sat(index);
        lon_interp = lon_sat(index);

        lon_interp(lon_interp > 0) = lon_interp(lon_interp > 0) - 360;
        zeta_interp = interp2(lon, lat, zeta, lon_interp, lat_interp);
        p = scatterm(lat_interp,lon_interp,20,zeta_interp*100,'o', 'Filled');

    end % di
end % mi

timenum_start = datenum(yyyy,mm,1);
timenum_end = datenum(yyyy,mm,dd);

title(t, {[datestr(timenum_start, 'mmm dd'), ' - ', datestr(timenum_end, 'mmm dd, yyyy')], ''}, 'FontSize', 15)
asdfasdf
print(['cmp_zeta_to_ICESat2_ATL21_', datestr(timenum_end, 'yyyymm')], '-dpng')

% save(['ADT_ICESat2_', ystr, '.mat'], 'data_ICESat2')