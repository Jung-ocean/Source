clear; clc

yyyy_all = 2012:2012;
mm_all = 6:6;
dd_all = 1:31;

nc_format = '/data/jungjih/Observations/Sea_ice/ASI/AMSR2/daily_polar/asi-AMSR2-n6250-20190501-v5.4.nc';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');
        for di = 1:eomday(yyyy,mm)
            dd = dd_all(di);
            dstr = num2str(dd, '%02i');

            filename = ['asi-SSMIS17-n6250-', ystr, mstr, dstr, '-v5'];
            filename_hdf = [filename, '.hdf'];
            filename_nc = [filename, '.nc'];
            copyfile(nc_format, filename_nc);

            z = hdfread(filename_hdf, 'ASI Ice Concentration');
            ncwrite(filename_nc, 'z', z')
        end
    end
end