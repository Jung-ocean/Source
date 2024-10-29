clear; clc

region = 'Gulf_of_Anadyr';
g = grd('BSf');
[mask, area] = mask_and_area(region, g);
mask(isnan(mask) == 1) = 0;
area(isnan(area) == 1) = 0;

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
        file = [filepath, filename];
        zeta = ncread(file, 'zeta')';
        salt = ncread(file, 'salt');
        salt = permute(salt, [3 2 1]);

        z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'w',2);
        dz = z_w(2:end,:,:) - z_w(1:end-1,:,:);

        mask3d = repmat(mask, [1, 1, g.N]);
        mask3d = permute(mask3d, [3 1 2]);

        area3d = repmat(area, [1, 1, g.N]);
        area3d = permute(area3d, [3 1 2]);

        salt(mask3d==0)=0; % zero out cells that are not needed, also fills nan spots
        dz(mask3d==0)=0;

        TV=sum(salt.*dz.*area3d,'all');
        V=sum(dz.*area3d,'all');
        Tave=TV/V;
        
        Sref(i) = Tave;

        disp(filename)
    end
end
dd
Sref(i) = NaN;
timenum_ref = timenum;

save(['Sref_', region, '.mat'], 'timenum_ref', 'Sref')