clear; clc

yyyy_all = 2011:2011;

ndye = 1;

g = grd('NP');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    
filename_dye = ['roms_ini_NP_case_01_', ystr, '.nc'];
%filename_dye = ['dye_roms_ini.nc'];

%copyfile(filename, filename_dye);

for i = 1:ndye
    
    dyenumber = num2char(i,2);
    vari_dye = ['dye_', dyenumber, '_age'];
    
    nccreate(filename_dye, vari_dye, 'Dimensions', {'xi_rho', 'eta_rho', 's_rho', 'ocean_time'});
    ncwriteatt(filename_dye, vari_dye, 'long_name', ['dye', dyenumber, ' concentration mean age'])
    ncwriteatt(filename_dye, vari_dye, 'units', 'second')
end

nc = netcdf(filename_dye, 'w');
nc{vari_dye}(:) = 0;
close(nc)

end

