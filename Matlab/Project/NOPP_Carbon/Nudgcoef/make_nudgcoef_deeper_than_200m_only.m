clear; clc

domain = 'Oregon_1km_large';
g = grd(domain);
h = g.h;
h_north = h(:,end);
h_south = h(:,1);

depth_target = 1000;
hnindex = find(h_north < depth_target);
hsindex = find(h_south < depth_target);

filename_org = 'nudgcoef_Oregon_1km_large_1day.nc';
filename = ['nudgcoef_Oregon_1km_large_1day_deeper_than_', num2str(depth_target), 'm.nc'];
copyfile(filename_org, filename);

band_width = 30;
temp_coef = ncread(filename, 'temp_NudgeCoef');
salt_coef = ncread(filename, 'salt_NudgeCoef');

temp_coef_new = [];
salt_coef_new = [];
for ni = 1:g.N
    temp_coef_tmp = temp_coef(:,:,ni);
    salt_coef_tmp = salt_coef(:,:,ni);

    % North
    temp_coef_tmp(hnindex(1):end,end-band_width*2:end) = 0;
    salt_coef_tmp(hnindex(1):end,end-band_width*2:end) = 0;
    
    % South
    temp_coef_tmp(hsindex(1):end,1:band_width*2) = 0;
    salt_coef_tmp(hsindex(1):end,1:band_width*2) = 0;

    temp_coef_new(:,:,ni) = temp_coef_tmp;
    salt_coef_new(:,:,ni) = salt_coef_tmp;
end

ncwrite(filename, 'temp_NudgeCoef', temp_coef_new);
ncwrite(filename, 'salt_NudgeCoef', salt_coef_new);