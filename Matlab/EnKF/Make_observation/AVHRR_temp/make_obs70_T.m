%
%
%

clear; clc;

%target_lon = [129.7, 125.8003, 125.1825]; target_lat = [37, 34.5442, 32.1231]; % point 1
%target_lon = [130.6011, 124.5928, 126.9658]; target_lat = [37.7428, 33.9419, 32.0903]; % point 2
%target_lon = [131.5525, 124.8877, 127.6924]; target_lat = [38.0072, 33.0325, 33.1564]; % point 3
%target_lon = [129 131 133 129.5 131.5 133.5 130 132 134]; target_lat = [40 40 40 38 38 38 36 36 36]; % point 4

% target_lon = [131.5525, 130.6011, 129.1214, 128.4189, 126.9603, ...
%     126.4922, 126.9658, 125.8003, 126.1942, 126.2703];
% target_lat = [38.0072, 37.7428, 34.9189, 34.2225, 34.2586, ...
%     33.9117, 32.0903, 34.5442, 35.6525, 37.0067];

% 2017_5 Taean -> Incheon
target_lon = [131.5525, 130.6011, 129.1214, 128.4189, 126.9603, ...
    126.4922, 126.9658, 125.8003, 126.1942, 126.5331];
target_lat = [38.0072, 37.7428, 34.9189, 34.2225, 34.2586, ...
    33.9117, 32.0903, 34.5442, 35.6525, 37.3894];


num_data = length(target_lon);

filepath = 'D:\Data\Satellite\AVHRR\daily\';

nod = 1; % number of observation file at each DA step

dayi = 7;

nc = netcdf([filepath, 'avhrr-only-v2.20030601.nc']);
lon = nc{'lon'}(:); lat = nc{'lat'}(:);
sst = nc{'sst'}(:);
sst = sst*nc{'sst'}.scale_factor(:) + nc{'sst'}.add_offset(:);
close(nc)
[lon2, lat2] = meshgrid(lon, lat);

fid=fopen('kalman_loof.par','w+');
fprintf(fid,'total time roof\n');

for i=1:num_data
    
    Distance = dist([target_lon(i)' target_lat(i)'], [lon2(:)'; lat2(:)']);
    
    Dindex = find(Distance == min(Distance));
    ind_lon_tmp = find(lon == lon2(Dindex));
    ind_lon(i) = ind_lon_tmp;
    ind_lat_tmp = find(lat == lat2(Dindex));
    ind_lat(i) = ind_lat_tmp;
    
%     if sst(ind_lat(i), ind_lon(i)) < 0
%         Distance(Dindex) = 1100;
%         % Iteration
%         Dindex = find(Distance == min(Distance));
%         ind_lon_tmp = find(lon == lon2(Dindex));
%         ind_lon(i) = ind_lon_tmp;
%         ind_lat_tmp = find(lat == lat2(Dindex));
%         ind_lat(i) = ind_lat_tmp;
%     end
    
    if i == 5
        ind_lon(i) = ind_lon_tmp + 1;
        ind_lat(i) = ind_lat_tmp - 1;
    end
    
end

for t = 1:dayi
    
    filename = ['avhrr-only-v2.200306', num2char(t+4,2), '.nc'];
    file = [filepath, filename];
    
    nc = netcdf(file);
    sst = nc{'sst'}(:);
    sst = sst*nc{'sst'}.scale_factor(:) + nc{'sst'}.add_offset(:);
    for i = 1:num_data
        olon(i) = lon(ind_lon(i));
        olat(i) = lat(ind_lat(i));
        otemp(i) = sst(ind_lat(i), ind_lon(i));
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