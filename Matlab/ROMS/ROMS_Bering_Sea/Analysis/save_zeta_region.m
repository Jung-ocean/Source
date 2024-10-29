clear; clc

region = 'Gulf_of_Anadyr';
g = grd('BSf');
[mask, area] = mask_and_area(region, g);

yyyy_all = 2019:2022;
mm_all = 1:12;

filepath = '/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/';

i = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);

    for mi = 1:length(mm_all)
        i = i+1;
        mm = mm_all(mi);
        timenum(i) = datenum(yyyy,mm,15);

        yyyymm = datestr(timenum(i), 'yyyymm');
        filename = ['Dsm2_spng_', yyyymm, '.nc'];
        try
            file = [filepath, filename];
            zeta = ncread(file, 'zeta')';

            zavg = sum(zeta(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
            zeta_region(i) = zavg;
        catch
            zeta_region(i) = NaN;
        end
        disp(filename)
    end
end

timenum_ref = timenum;
save(['zeta_', region, '.mat'], 'timenum_ref', 'zeta_region')