clear; clc

region = 'Gulf_of_Anadyr';
g = grd('BSf');
startdate = datenum(2018,7,1);
[mask, area] = mask_and_area(region, g);
mask(isnan(mask) == 1) = 0;
area(isnan(area) == 1) = 0;

yyyy_all = 2019:2022;
mm_all = 1:8;

filepath = '/data/sdurski/ROMS_BSf/Output/Multi_year/Dsm4/';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    start_day=datenum(yyyy,mm_all(1),1)-1; % -1 because there is 12h delay of ocean_time in the output file
    end_day=datenum(yyyy,mm_all(end)+1,1);
    timenum_ref = start_day:end_day;

    ind_start = start_day - startdate;
    ind_end = end_day - startdate;

    i = 0;
    Sref = NaN;
    for fi = ind_start:ind_end
        i = i+1;
        filenum = fi;
        fstr = num2str(filenum, '%04i');

        filename = ['Dsm4_avg_', fstr, '.nc'];
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
    save(['Sref_', region, '_', ystr, '.mat'], 'timenum_ref', 'Sref')
end
