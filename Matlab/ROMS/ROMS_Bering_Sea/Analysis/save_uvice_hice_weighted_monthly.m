%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save sea ice thickness weighted monthly average of sea ice velocity
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
yyyy_all = 2019:2022;
mm_all = 1:7;
startdate = datenum(2018,7,1);

g = grd('BSf');

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        
        fnum_start = datenum(yyyy,mm,1) - startdate + 1;
        fnum_end = datenum(yyyy,mm,eomday(yyyy,mm)) - startdate + 1;
        
        huice_sum = zeros;
        hvice_sum = zeros;
        hice_sum = zeros;
        for fi = fnum_start:fnum_end
        
            filenum = fi; fstr = num2str(filenum, '%04i');
            filename = [exp, '_avg_', fstr, '.nc'];
            file = [filepath, filename];

            hice = ncread(file, 'hice')';
            uice = ncread(file, 'uice')';
            vice = ncread(file, 'vice')';

            skip = 1;
            npts = [0 0 0 0];

            [uice_rho,vice_rho,lonred,latred,maskred] = uv_vec2rho(uice,vice,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
            uice_rho = uice_rho.*maskred;
            vice_rho = vice_rho.*maskred;

            huice_sum = huice_sum + hice.*uice_rho;
            hvice_sum = hvice_sum + hice.*vice_rho;
            hice_sum = hice_sum + hice;
        end
        uice_wmean = huice_sum./hice_sum;
        vice_wmean = hvice_sum./hice_sum;

        save(['uvice_hice-weighted_monthly_', ystr, mstr], 'uice_wmean', 'vice_wmean')
        disp([ystr, mstr, '...'])
    end
end

