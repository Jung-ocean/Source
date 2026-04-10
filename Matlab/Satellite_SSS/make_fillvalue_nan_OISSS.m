clear; clc

yyyy_all = 2011:2024;
mm_all = 1:12;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filepath = ['/data/jungjih/Observations/Satellite_SSS/OISSS/monthly/'];
        filename = ['OISSS_L4_multimission_global_monthly_v2.0_', ystr, '-', mstr, '.nc'];
        file = [filepath, filename];

        command = ['ncatted -a _FillValue,sss,o,f,NaN ', file];
        system(command)
    end
end