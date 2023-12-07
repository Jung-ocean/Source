clear; clc;

[target_lon, target_lat] = read_point_2017('2017');
num_data = length(target_lon);

filepath = 'G:\DataAssimilation\case\2017_7\observation\';

nod = 1; % number of observation file at each DA step
depth_ind = 40;

initial_num = 121; % difference of julian day between starting and 1st Jan xxxx
dayi = 7;

g = grd('NWP');
lon_rho = g.lon_rho; lon = lon_rho(1,:);
lat_rho = g.lat_rho; lat = lat_rho(:,1);
mask_rho = g.mask_rho;
mask_rho2 = mask_rho./mask_rho;

fid=fopen('kalman_loof.par','w+');
fprintf(fid,'total time roof\n');

for i=1:num_data
    dist_lon = (target_lon(i) - lon).^2;
    dist_lat = (target_lat(i) - lat).^2;
    
    ind_lon_tmp = find(dist_lon == min(dist_lon));
    ind_lon(i) = ind_lon_tmp(1);
    ind_lat(i) = find(dist_lat == min(dist_lat));
end

for t = 1:dayi
    filename = ['his_', num2char(t + initial_num, 4), '.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    for i = 1:num_data
        olon(i) = lon_rho(ind_lat(i), ind_lon(i));
        olat(i) = lat_rho(ind_lat(i), ind_lon(i));
        otemp(i) = nc{'temp'}(end, depth_ind, ind_lat(i), ind_lon(i));
    end
    close(nc)
    
    fprintf(fid,'%5d\n', nod);
    
    obsfile = ['obs_temp_', num2char(t, 4), '_', num2char(nod, 4), '.nc'];
    
    nc_data_obs(obsfile,num_data);
    
    nc = netcdf(obsfile,'w');
    nc{'dindex'}(1,1:num_data) = 2;
    nc{'ixt'}(:) = 1:num_data;
    nc{'ndata'}(:) = num_data;
    nc{'rdepth'}(:) = zeros(1,num_data);
    nc{'rlon'}(1,1:num_data) = olon(1,1:num_data);
    nc{'rlat'}(1,1:num_data) = olat(1,1:num_data);
    nc{'obsdata'}(1,1:num_data) = otemp(1,1:num_data);
    nc{'obserr'}(1,1:num_data) = 0.1;
    close(nc)
end

fclose(fid);