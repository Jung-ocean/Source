%
%
%

clear; clc;

%target_lon = [129.7, 125.8003, 125.1825]; target_lat = [37, 34.5442, 32.1231]; % point 1
%target_lon = [130.6011, 124.5928, 126.9658]; target_lat = [37.7428, 33.9419, 32.0903]; % point 2
target_lon = [131.5525, 124.8877, 127.6924]; target_lat = [38.0072, 33.0325, 33.1564]; % point 3
%target_lon = [129 131 133 129.5 131.5 133.5 130 132 134]; target_lat = [40 40 40 38 38 38 36 36 36]; % point 4
num_data = length(target_lon);

filepath = 'D:\Data\Ocean\Model\ROMS\NWP\exp_3\year10\';

nod = 1; % number of observation file at each DA step
depth_ind = 40;

diff_date = 212; % difference of julian day between starting and 1st Jan xxxx
dayi = 10;

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
    filename = ['avg_', num2char(t + diff_date, 4), '.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    temp = nc{'temp'}(:);
    salt = nc{'salt'}(:);
    close(nc)
    
    for i = 1:num_data
        olon(i) = lon_rho(ind_lat(i), ind_lon(i));
        olat(i) = lat_rho(ind_lat(i), ind_lon(i));
        odata(i) = temp(depth_ind, ind_lat(i), ind_lon(i));
        dindex(i) = 2;
    end
    for i = 1:num_data
        olon(num_data+i) = lon_rho(ind_lat(i), ind_lon(i));
        olat(num_data+i) = lat_rho(ind_lat(i), ind_lon(i));
        odata(num_data+i) = salt(depth_ind, ind_lat(i), ind_lon(i));
        dindex(num_data+i) = 3;
    end
    
    
    fprintf(fid,'%5d\n', nod);
    
    obsfile = ['obs_TS_', num2char(t, 4), '_', num2char(nod, 4), '.nc'];
    
    num_data2 = num_data*2;
    nc_data_obs(obsfile,num_data2);
    
    nc = netcdf(obsfile,'w');
    nc{'dindex'}(1,1:num_data2) = dindex;
    nc{'ixt'}(:) = 1:num_data2;
    nc{'ndata'}(:) = num_data2;
    nc{'rdepth'}(:) = zeros(1,num_data2);
    nc{'rlon'}(1,1:num_data2) = olon(1,1:num_data2);
    nc{'rlat'}(1,1:num_data2) = olat(1,1:num_data2);
    nc{'obsdata'}(1,1:num_data2) = odata(1,1:num_data2);
    nc{'obserr'}(1,1:num_data2) = 0.1;
    close(nc)
end

fclose(fid);