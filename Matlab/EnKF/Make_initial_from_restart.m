clear; clc

g = grd('NWP');
rst_path = '.\';
tindex = 1;

for ri = 1:32;
    initialname = ['ocean_rst_ens', num2char(ri,2), '_in.nc'];
    
    rfilename = ['ocean_rst_ens', num2char(ri,2), '_out.nc'];
    rfile = [rst_path, rfilename];
    rnc = netcdf(rfile);
    temp = rnc{'temp'}(tindex,:,:,:);
    size_temp = size(temp);
    
    create_empty_initial(initialname, size_temp)
        
    inc = netcdf(initialname, 'w');
    inc{'lat_rho'}(:) = g.lat_rho; inc{'lon_rho'}(:) = g.lon_rho;
    inc{'temp'}(:) = rnc{'temp'}(tindex,:,:,:); inc{'salt'}(:) = rnc{'salt'}(tindex,:,:,:);
    inc{'u'}(:) = rnc{'u'}(tindex,:,:,:); inc{'v'}(:) = rnc{'v'}(tindex,:,:,:);
    inc{'ubar'}(:) = rnc{'ubar'}(tindex,:,:); inc{'vbar'}(:) = rnc{'vbar'}(tindex,:,:);
    inc{'zeta'}(:) = rnc{'zeta'}(tindex,:,:);
    inc{'ocean_time'}(:) = rnc{'ocean_time'}(tindex);
    close(inc)
    close(rnc)
    
end