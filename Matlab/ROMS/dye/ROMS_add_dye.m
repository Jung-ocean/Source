clear; clc

yyyy_all = 2011:2011;

ndye = 1;

g = grd('NP');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
%filename_dye = ['roms_ini_NP_case_01_', ystr, '.nc'];
%filename_dye = ['dye_roms_ini.nc'];
%filename_dye = ['roms_ini_upwelling_ideal_1km_flat_21_a5_10days_dye.nc'];
% filename_dye = ['avg_0015_dye.nc'];
filename_dye = 'Yearly_2023_02_28.nc';

%copyfile(filename, filename_dye);

for i = 1:ndye
    
    dyenumber = num2char(i,2);
    vari_dye = ['dye_', dyenumber];
    
    nccreate(filename_dye, vari_dye, 'Dimensions', {'xi_rho', 'eta_rho', 's_rho', 'ocean_time'});
    ncwriteatt(filename_dye, vari_dye, 'long_name', ['dye', dyenumber, ' concentration'])
    ncwriteatt(filename_dye, vari_dye, 'units', 'kg meter-3')
end

end