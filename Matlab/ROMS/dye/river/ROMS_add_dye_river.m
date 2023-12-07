clear; clc

ndye = 1;

yyyy_all = 2011:2020;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

filename_dye = ['roms_river_NP_', ystr, '.nc'];

for i = 1:ndye
    
    dyenumber = num2char(i,2);
    vari_dye = ['river_dye_', dyenumber];
    
    nccreate(filename_dye, vari_dye, 'Dimensions', {'river', 's_rho', 'river_time'});
    ncwriteatt(filename_dye, vari_dye, 'long_name', ['river runoff dye concentration'])
    ncwriteatt(filename_dye, vari_dye, 'units', 'kg meter-3')
end
end