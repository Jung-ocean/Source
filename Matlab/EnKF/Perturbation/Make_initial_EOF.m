%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Make ensemble initial using Karhunen-Loeve expansion (EOF)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

%% Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The number of ensemble and the number of mode
num_Ensemble = 1;
num_Mode = 5; % usually 5

% Variable lists
varis = {'temp', 'salt', 'u', 'v', 'zeta'};
varis_3d = {'temp', 'salt', 'u', 'v'};
varis_2d = {'zeta'};

% Model output path and file number
filepath = 'D:\Data\Ocean\Model\ROMS\NWP\exp_1\year7\';
file_start = 91; % start file number
file_end = 120; % end file number
file_base = 91; % file number to be perturbated
num_file = file_end - file_start + 1;

% Grid file path
grdfilepath = 'G:\Model\ROMS\Case\ROMS_북서태평양_용진이형\NWP\';
grdfilename = 'roms_grid_combine2.nc';
grdfile = [grdfilepath, grdfilename];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Making ensemble initial using Karhunen_Loeve expansion'); disp(' ');
disp(['The number of ensemble = ', num2str(num_Ensemble)])
disp(['Variable lists = ', sprintf('%s ', varis{:})])
disp(['Grid file = ', grdfile]); disp(' ');

%% Read grid file
nc = netcdf(grdfile);
mask_rho = nc{'mask_rho'}(:); mask_u = nc{'mask_u'}(:); mask_v = nc{'mask_v'}(:);
lon_rho = nc{'lon_rho'}(:); lat_rho = nc{'lat_rho'}(:);
lon_u = nc{'lon_u'}(:); lon_v = nc{'lon_v'}(:);
lat_u = nc{'lat_u'}(:); lat_v = nc{'lat_v'}(:);
close(nc)

%% Read data from model output files
dayi=0;
for di = file_start:file_end % day index
    dayi = dayi+1;
    
    % Read variables
    filename = ['avg_', num2char(di,4), '.nc'];
    file = [filepath, filename];
    nc = netcdf(file);
    temp = nc{'temp'}(:); salt = nc{'salt'}(:); zeta = nc{'zeta'}(:);
    u = nc{'u'}(:); v = nc{'v'}(:);
    close(nc)
    disp(['Reading... ', file])
    
    % Sizes of variables
    size_temp = size(temp); size_salt = size(salt); size_zeta = size(zeta);
    size_u = size(u); size_v = size(v);
    
    % NaN processing
    for i = 1:size_temp(1);
        temp(i,:,:) = squeeze(temp(i,:,:)).*mask_rho./mask_rho;
        salt(i,:,:) = squeeze(salt(i,:,:)).*mask_rho./mask_rho;
        u(i,:,:) = squeeze(u(i,:,:)).*mask_u./mask_u;
        v(i,:,:) = squeeze(v(i,:,:)).*mask_v./mask_v;
    end
    zeta = zeta.*mask_rho./mask_rho;
    
    % Combine data
    temp_all(dayi,:,:,:) = temp;
    salt_all(dayi,:,:,:) = salt;
    zeta_all(dayi,:,:) = zeta;
    u_all(dayi,:,:,:) = u;
    v_all(dayi,:,:,:) = v;
end

%% Ensemble base
filename = ['avg_', num2char(file_base, 4), '.nc'];
file = [filepath, filename];
nc = netcdf(file);
temp_base = nc{'temp'}(:); salt_base = nc{'salt'}(:); zeta_base = nc{'zeta'}(:);
u_base = nc{'u'}(:); v_base = nc{'v'}(:);
close(nc)

%% Average
temp_mean = squeeze(nanmean(temp_all));
salt_mean = squeeze(nanmean(salt_all));
u_mean = squeeze(nanmean(u_all));
v_mean = squeeze(nanmean(v_all));
zeta_mean = squeeze(nanmean(zeta_all));

ubar_mean(:,:) = mean(u_mean);
vbar_mean(:,:) = mean(v_mean);

% Make empty file and input average data into the file
avg_file_name = 'initial_average.nc';
create_empty_initial(avg_file_name, size_temp)
nc = netcdf(avg_file_name, 'w');
nc{'lat_rho'}(:) = lat_rho; nc{'lon_rho'}(:) = lon_rho;
nc{'temp'}(:) = temp_mean; nc{'salt'}(:) = salt_mean;
nc{'u'}(:) = u_mean; nc{'v'}(:) = v_mean;
nc{'ubar'}(:) = ubar_mean; nc{'vbar'}(:) = vbar_mean;
nc{'zeta'}(:) = zeta_mean;
close(nc)

%% Detrend
linear_str = 'linear';
for vi = 1:length(varis) % var index
    var = varis{vi};
    eval([var, '_state = ', var, '_all(:,:);'])
    eval(['clearvars ' , var, '_all;'])
    eval([var, '_state_detrend = detrend(', var, '_state, linear_str);'])
    %eval([var, '_state_detrend =', var, '_state;'])
    eval([var, '_all_detrend = reshape(', var, '_state_detrend, [num_file, size_', var, ']);'])
end

%% Detrended average
temp_mean_detrend = squeeze(nanmean(temp_all_detrend));
salt_mean_detrend = squeeze(nanmean(salt_all_detrend));
u_mean_detrend = squeeze(nanmean(u_all_detrend));
v_mean_detrend = squeeze(nanmean(v_all_detrend));
zeta_mean_detrend = squeeze(nanmean(zeta_all_detrend));

%% Calculate average spatial standard deviation and Normalize the anomlies
% 3-D variables (temp, salt, u, v)
for vi = 1:length(varis_3d) % var index
    var = varis_3d{vi};
    eval(['vari_vertical_state = ', var, '_all_detrend(:,:,:);'])
    eval(['vari_mean_vertical_state = ', var, '_mean(:,:);'])
    
    for fi = 1:num_file % file index
        for vli = 1:size_temp(1) % vertical layer index
            deviation = squeeze(vari_vertical_state(fi,vli,:))' - vari_mean_vertical_state(vli, :);
            variation = nanmean(deviation.^2);
            eval([var, '_std(fi,vli) = sqrt(variation);'])
            eval([var, '_final_state(fi, vli, :) = deviation./sqrt(variation);'])
        end
    end
    eval([var, '_final = reshape(', var, '_final_state, [num_file, size_', var, ']);'])
end

% 2-D variable (zeta)
zeta_state = zeta_all_detrend(:,:);
zeta_mean_state = zeta_mean(:);
for fi = 1:num_file
    deviation = squeeze(zeta_state(fi,:))' - zeta_mean_state;
    variation = nanmean(deviation.^2);
    zeta_std(fi,:) = sqrt(variation);
    zeta_final_state(fi,:) = deviation./sqrt(variation);
end
zeta_final = reshape(zeta_final_state, [num_file, size_zeta]);

%% Separate whole data into data points and NaN points
for fi = 1:num_file % file index
    
    temp_state = temp_final(fi,:);
    salt_state = salt_final(fi,:);
    u_state = u_final(fi,:);
    v_state = v_final(fi,:);
    zeta_state = zeta_final(fi,:);
    
    pre_data = [temp_state salt_state u_state v_state zeta_state];
    data_nan_point = find(isnan(pre_data) == 1);
    data_point = find(isnan(pre_data) == 0);
    
    temp_nan = isnan(temp_state); temp_state_noNaN = temp_state((isnan(temp_state) == 0));
    salt_nan = isnan(salt_state); salt_state_noNaN = salt_state((isnan(salt_state) == 0));
    u_nan = isnan(u_state); u_state_noNaN = u_state((isnan(u_state) == 0));
    v_nan = isnan(v_state); v_state_noNaN = v_state((isnan(v_state) == 0));
    zeta_nan = isnan(zeta_state); zeta_state_noNaN = zeta_state((isnan(zeta_state) == 0));
    
    data_final(fi,:) = [temp_state_noNaN salt_state_noNaN u_state_noNaN v_state_noNaN zeta_state_noNaN];
end
%clear temp_all salt_all u_all v_all zeta_all;
clear temp_final salt_final u_final v_final zeta_final;
clear temp_all_detrend salt_all_detrend u_all_detrend v_all_detrend zeta_all_detrend

%% EOF analysis
[m ,n] = size(data_final);
[u, s, v] = svds(data_final', num_Mode);

Eigen_Value = diag(s.^2);
sq_Eigen_Value = sqrt(Eigen_Value);

% Squared covariance fraction (SCF)
scf = Eigen_Value./sum(Eigen_Value);

%% Ensemble loop
for ei = 1:num_Ensemble % ensemble index
    disp(['Ensemble number ', num2str(ei), '/', num2str(num_Ensemble)])
    %% Make perturbation
    % random_number*sqrt(eigen value)*eigen vector
    for mi = 1:num_Mode % mode index
        Eigen_Vector = squeeze(u(:,mi));
        k_random_num = 0.1* (rand * (-1)^floor(rand*10));
        KLE_mode(mi,:) = k_random_num.*sq_Eigen_Value(mi).*Eigen_Vector;
    end
    KLE_noNaN = sum(KLE_mode);% Karhunen-Loeve expansion (KLE)
    
    % Make full size KLE matrix
    KLE = 1e37*(1:(length(data_point)+length(data_nan_point)));
    for dpi = 1:length(data_point) % data point index
        KLE(data_point(dpi)) = KLE_noNaN(dpi);
    end
    
    % Separate full size KLE matrix into each variables
    % 3-D variables
    for vi = 1:length(varis_3d)
        var = varis_3d{vi};
        eval(['len_', var, '_state = length(', var, '_state);'])
        eval([var, '_KLE_state = KLE(1:len_', var, '_state);'])
        eval([var, '_KLE = reshape(', var, '_KLE_state, [size_', var, ']);'])
        eval(['KLE(1:len_', var, '_state) = [];'])
    end
    % 2-D variable
    len_zeta_state = length(zeta_state);
    zeta_KLE_state = KLE(1:end);
    zeta_KLE = reshape(zeta_KLE_state, [size_zeta]);
    
    %% Make final data
    % Mean_data + KLE matrix
    
    %     final_temperature = temp_mean + temp_KLE;
    %     final_salinity = salt_mean + salt_KLE;
    %     final_u = u_mean + u_KLE;
    %     final_v = v_mean + v_KLE;
    %     final_zeta = zeta_mean + zeta_KLE;
    final_temperature = temp_base + temp_KLE;
    final_salinity = salt_base + salt_KLE;
    final_u = u_base + u_KLE;
    final_v = v_base + v_KLE;
    final_zeta = zeta_base + zeta_KLE;
    
    final_ubar(:,:) = mean(final_u);
    final_vbar(:,:) = mean(final_v);
    
    %% Make empty initial files and input data into the files
    ens_file_name = ['ocean_rst_ens', num2char(ei,2), '_in.nc'];
    create_empty_initial(ens_file_name, size_temp)
    nc = netcdf(ens_file_name, 'w');
    nc{'lat_rho'}(:) = lat_rho; nc{'lon_rho'}(:) = lon_rho;
    nc{'temp'}(:) = final_temperature; nc{'salt'}(:) = final_salinity;
    nc{'u'}(:) = final_u; nc{'v'}(:) = final_v;
    nc{'ubar'}(:) = final_ubar; nc{'vbar'}(:) = final_vbar;
    nc{'zeta'}(:) = final_zeta;
    close(nc)
end