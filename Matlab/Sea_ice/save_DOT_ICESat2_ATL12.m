%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save DOT (SSH-SSB-geoid) from ICESat2 ATL12
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2022;
mm_all = 2:2;

g = grd('BSf');

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/DOT/data/';

ystr = num2str(yyyy);

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'k')

gts = {'gt1l', 'gt1r', 'gt2l', 'gt2r', 'gt3l', 'gt3r'};

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        filename_all = dir([filepath, 'ATL12_', ystr, mstr, dstr, '*']);

        for ni = 1:length(filename_all)

            filename = filename_all(ni).name;
            file = [filepath, filename];

            for gi = 1:length(gts)
                gt = gts{gi};

                lat = h5read(file, ['/', gt, '/ssh_segments/latitude']);
                lon = h5read(file, ['/', gt, '/ssh_segments/longitude']);

                h = h5read(file, ['/', gt, '/ssh_segments/heights/h']);

                % ssb variable name, https://nsidc.org/sites/default/files/documents/user-guide/atl12-v006-userguide.pdf
                ssb = h5read(file, ['/', gt, '/ssh_segments/heights/bin_ssbias']);
                fv = h5readatt(file, ['/', gt, '/ssh_segments/heights/bin_ssbias'],'_FillValue');
                ssb(ssb == fv) = NaN;

                % geoid variable name, https://icesat-2.gsfc.nasa.gov/sites/default/files/page_files/ICESat2_ATL12_ATBD_r006.pdf
                geoid = h5read(file, ['/', gt, '/ssh_segments/stats/geoid_seg']);
                fv = h5readatt(file, ['/', gt, '/ssh_segments/stats/geoid_seg'],'_FillValue');
                geoid(geoid == fv) = NaN;

                DOT = h - geoid;% - ssb;

                p(ni,gi) = scatterm(lat,lon,5,DOT*100,'o');
                colormap jet
                caxis([-10 50])
                c = colorbar;
                c.Title.String = 'cm';

            end % gi
        end % ni
%         delete(p);
    end % di
end % mi

timenum_start = datenum(yyyy,mm,1);
timenum_end = datenum(yyyy,mm,dd);

title([datestr(timenum_start, 'mmm dd'), ' - ', datestr(timenum_end, 'mmm dd, yyyy')])

print(['DOT_ICESat2_ATL12_', datestr(timenum_end, 'yyyymm')], '-dpng')

% save(['ADT_ICESat2_', ystr, '.mat'], 'data_ICESat2')