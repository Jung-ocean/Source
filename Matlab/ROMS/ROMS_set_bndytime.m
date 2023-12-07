clear; clc; close all

yyyy_all = 2011:2020;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    
    %filename_dye = ['roms_bndy_NP_GLORYS_', ystr, '.nc'];
    filename_dye = ['roms_NP_bry2_SODA-Y', ystr, '.nc'];
    nc = netcdf(filename_dye, 'w');
    
    varis = {'ocean', 'bry', 'zeta', 'temp', 'salt', ...
        'u2d', 'u3d', 'v2d', 'v3d', 'tclm', 'sclm', ...
        'uclm', 'vclm', 'ssh', 'dye'};
    
    for vi = 1:length(varis)
        vari = varis{vi};
        try
            nc{[vari, '_time']}(:) = [15:30:365];
        catch
        end
    end
    
    close(nc)
    
end