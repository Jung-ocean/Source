clear; clc

num_ens = 32;
Ne = num_ens;

for ei = 1:num_ens
    filename = ['ocean_rst_ens', num2char(ei,2),'_in.nc'];
    nc = netcdf(filename);
    temp = nc{'temp'}(40,:,:);
    temp_all(ei,:,:) = temp;
    close(nc)
      
end

temp_all_mean = squeeze(mean(temp_all));
clearvars temp_all
temp_all_mean_state = temp_all_mean(:);
temp_all_mean_state(temp_all_mean_state > 1000) = [];
Ns = length(temp_all_mean_state);

devi_sum = zeros;
for ei = 1:num_ens
    filename = ['ocean_rst_ens', num2char(ei,2),'_in.nc'];
    nc = netcdf(filename);
    temp = nc{'temp'}(40,:,:);
    temp_state = temp(:);
    temp_state(temp_state > 1000) = [];
    
    devi_sum = devi_sum + sum((temp_all_mean_state - temp_state).^2);
    
    close(nc)
end

EnSP = sqrt(  devi_sum/(  Ns*(Ne-1)  )  );