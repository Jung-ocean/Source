clear; clc

yyyy_all = 2011:2022;
mm_all = 1:12;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        filepath = ['/data/jungjih/Observations/Satellite_SSS/BEC/Arctic/v4/monthly/'];
        filename = ['BEC_SSS___SMOS__ARC_L3__B_', ystr, mstr, '_25km__9d_REP_v4.0.nc'];
        file = [filepath, filename];

        command = ['ncatted -a _FillValue,sss,o,f,NaN ', file];
        system(command)
    end
end