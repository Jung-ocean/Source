clear; clc;

N_new = 200;
Nstr = num2str(N_new);

g = grd('BSf');
theta_s = g.theta_s;
theta_b = g.theta_b;
hc = g.hc;

grid_org = '../grid/grid_1D_DP.nc';
depth = ncread(grid_org, 'h');
depth = mean(depth(:));

% Original file
file_org = 'initial_1D_DP_N45.nc';
temp_org = ncread(file_org, 'temp');
N_org = size(temp_org, 3);
z_r_org = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N_org,'r',2));

info = ncinfo(file_org);

% New file
file_new = ['initial_1D_DP_N', Nstr, '.nc'];

info.Dimensions(strcmp({info.Dimensions.Name}, 's_rho')).Length = N_new;
info.Dimensions(strcmp({info.Dimensions.Name}, 's_w')).Length = N_new+1;
for vi = 1:length(info.Variables)
    for di = 1:length(info.Variables(vi).Dimensions)
        if strcmp(info.Variables(vi).Dimensions(di).Name, 's_rho')
            info.Variables(vi).Dimensions(di).Length = N_new;
        end
        if strcmp(info.Variables(vi).Dimensions(di).Name, 's_w')
            info.Variables(vi).Dimensions(di).Length = N_new+1;
        end
    end
end

ncwriteschema(file_new, info);

% Find variables with vertical dimensions (4D)
fourD_vars = {};  % 4D
for i = 1:length(info.Variables)
    dims = info.Variables(i).Dimensions;
    if length(dims) == 4
        fourD_vars{end+1} = info.Variables(i).Name;
    end
end

% Write variables with dimensions less than 4 as is
lowD_vars = setdiff({info.Variables.Name}, fourD_vars);
for v = lowD_vars
    data = ncread(file_org, v{1});
    ncwrite(file_new, v{1}, data);
    atts = ncinfo(file_org, v{1}).Attributes;
    for a = 1:length(atts)
        ncwriteatt(file_new, v{1}, atts(a).Name, atts(a).Value);
    end
end

% Write variables which have vertical dimesions after vertical
% interpolation
z_r_new = squeeze(zlevs(depth,0,theta_s,theta_b,hc,N_new,'r',2));

for v = fourD_vars
    data4D = ncread(file_org, v{1});  % [t, y, x, rho=45]
    [nx, ny, nz, ~] = size(data4D);
    
    new_data4D = zeros(nx, ny, N_new, class(data4D));
    for i=1:nx
        for j=1:ny
            new_data4D(i,j,:) = interp1(z_r_org, squeeze(data4D(i,j,:)), z_r_new, 'linear', 'extrap');
        end
    end
    ncwrite(file_new, v{1}, new_data4D);
end

temp_org = ncread(file_org, 'temp');
temp_org = squeeze(mean(mean(temp_org,1),2));
temp_new = ncread(file_new, 'temp');
temp_new = squeeze(mean(mean(temp_new,1),2));

salt_org = ncread(file_org, 'salt');
salt_org = squeeze(mean(mean(salt_org,1),2));
salt_new = ncread(file_new, 'salt');
salt_new = squeeze(mean(mean(salt_new,1),2));

figure; hold on; grid on;
t = tiledlayout(1,2);

nexttile(1); hold on; grid on;
plot(temp_org, z_r_org, 'rx')
plot(temp_new, z_r_new, 'bo')

nexttile(2); hold on; grid on;
plot(salt_org, z_r_org, 'rx')
plot(salt_new, z_r_new, 'bo')