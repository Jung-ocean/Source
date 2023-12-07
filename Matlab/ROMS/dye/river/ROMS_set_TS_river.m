clear; clc; close all

g = grd('NP');

river_ind = 13;

yyyy_all = [2012:2012];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

filename_dye = ['roms_river_NP_', ystr, '.nc'];
nc = netcdf(filename_dye, 'w');
Epos = nc{'river_Eposition'}(river_ind,1);
Xpos = nc{'river_Xposition'}(river_ind,1);

filepath = 'G:\내 드라이브\Model\ROMS\Case\NP\output\exp_Fukushima\2011\';
for mi = 1:12
    mstr = num2char(mi,2);
    filename = ['monthly_2011', mstr, '.nc'];
    file = [filepath, filename];
    fnc = netcdf(file);
    temp(mi) = fnc{'temp'}(1,g.N,Epos+1,Xpos+1);
    salt(mi) = fnc{'salt'}(1,g.N,Epos+1,Xpos+1);
    close(fnc)
    
end

for ni = 1:g.N
    nc{'river_temp'}(:,ni,river_ind) = temp;
    nc{'river_salt'}(:,ni,river_ind) = salt;
end

close(nc)
end