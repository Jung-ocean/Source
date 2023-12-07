clc; clear

file1 = 'roms_bndy_NWP_HYCOM_2001.nc';
file2 = 'roms_bndy_NWP_SODA3_2001.nc';
file3 = 'roms_bndy_NWP_combine_2001.nc';

copyfile(file1, file3);

varis = {'salt', 'temp', 'u', 'ubar', 'v', 'vbar', 'zeta'};
dirs = {'east', 'north', 'south', 'west'};

nc1 = netcdf(file1);
nc2 = netcdf(file2);
nc3 = netcdf(file3, 'w');

for vi = 1:length(varis)
    for di = 1:length(dirs)
        vari = [varis{vi}, '_', dirs{di}];
        vari1 = nc1{vari}(:);
        vari2 = nc2{vari}(:);
        vari_mean = (vari1 + vari2)/2;
        
        nc3{vari}(:) = vari_mean;
    end
end

close(nc1);
close(nc2);
close(nc3);
        