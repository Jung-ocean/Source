clear; clc

yyyy_all = 2015:2025;
mm_all = 1:12;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filepath = ['/data/jungjih/Observations/Satellite_SSS/RSS/v6.0/monthly/', ystr, '/'];
        filename = ['RSS_smap_SSS_L3_monthly_', ystr, '_', mstr, '_FNL_v06.0.nc'];
        file = [filepath, filename];

        command = ['ncatted -a _FillValue,sss_smap,o,f,NaN ', file];
        system(command)
    end
end