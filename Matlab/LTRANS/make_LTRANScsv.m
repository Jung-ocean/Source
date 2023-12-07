clear; clc

output = 'floats_Fukushima.csv';

depth = [-2];

% NWP
%lon = [127.0000, 128.2000, 129.5500, 131.2000, 133.0000]; %, 135.4000];
%lat = [21.0000; 19.9933; 18.8608; 17.4767; 15.9667];% 13.9533];
%cluster_matrix = [-0.1 -0.1; -0.1 0; -0.1 0.1; 0 -0.1; 0 0; 0 0.1; 0.1 -0.1; 0.1 0; 0.1 0.1];

% ECS
%lon = [129.24 127.75 126.248 125.248 125.248 125.248 126.248 127.249 128.742];
%lat = [34.90 33.83 33.75 33.28 32.48 31.48 32.48 33.38 34.14];
%cluster_matrix = [-0.1 -0.1; -0.1 0; -0.1 0.1; 0 -0.1; 0 0; 0 0.1; 0.1 -0.1; 0.1 0; 0.1 0.1];

% Fukushima
lon = [141.0325 141.0325 141.0325];
lat = [37.4214 37.4214 37.4214];
cluster_matrix = [0 0];

num_day = 365;

data = [];
for di = 1:length(depth)
    for li = 1:length(lon)
        
        lon_tmp = lon(li); lat_tmp = lat(li);
        lonlat_cluster = repmat([lon_tmp lat_tmp], [length(cluster_matrix),1]) + cluster_matrix;
        
        for ci = 1:length(lonlat_cluster)
            data = [data; lonlat_cluster(ci,1), lonlat_cluster(ci,2), depth(di), 43200, 101001];
        end
    end
end

len_data = length(data);
data_all = [];
for di = 1:num_day
    data_all = [data; data_all];
    data_all(1:len_data,4) = data_all(1:len_data,4) + (di-1)*43200;
end

fid = fopen(output,'w');
for i = 1:length(data_all)
    fprintf(fid, '%10f %10f %6i %6i %6i',data_all(i,:));
    fprintf(fid,'\r\n');
end
fclose(fid);