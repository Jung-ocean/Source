%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Perturb ECMWF wind using Karhunen-Loeve expansion (EOF)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

%% Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_datenum = datenum(2003,1,1,0,0,0);
end_datenum = datenum(2003,12,31,18,0,0);

% The number of ensemble and the number of mode
num_Ensemble = 32;
num_Mode = 5; % usually 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perturbation_date = str2num(datestr(start_datenum:end_datenum, 'yyyymmdd'));

disp('Perturbing wind forcing using Karhunen_Loeve expansion'); disp(' ');
disp(['The number of ensemble = ', num2str(num_Ensemble)])

%% File
filepath = 'D:\Data\Atmosphere\ECMWF_interim\';
filename = '2003-1.nc';
file = [filepath, filename];

%% Read netcdf file
nc = netcdf(file);
u = nc{'u10'}(:); v = nc{'v10'}(:);
u_scale_factor = nc{'u10'}.scale_factor(:); u_add_offset = nc{'u10'}.add_offset(:);
v_scale_factor = nc{'v10'}.scale_factor(:); v_add_offset = nc{'v10'}.add_offset(:);
lat = nc{'latitude'}(:); lon = nc{'longitude'}(:); [xx,yy] = meshgrid(lon,lat);
time = nc{'time'}(:);
close(nc)

u = u.*u_scale_factor + u_add_offset;
v = v.*v_scale_factor + v_add_offset;
date = datestr(time/24 + datenum(1900,01,01), 'yyyymmdd');

%% Calculate daily mean
wind_datenum = datenum(date, 'yyyymmdd');
datenum_list = unique(wind_datenum);
day_list = str2num(datestr(datenum_list, 'yyyymmdd'));

for di = 1:length(datenum_list)
    index_daily = find(wind_datenum == datenum_list(di));
    u_daily(di,:,:) = mean(u(index_daily,:,:));
    v_daily(di,:,:) = mean(v(index_daily,:,:));
end

%% Extraction of target date
for pi = 1:length(perturbation_date) % perturbation index
    index(pi) = find(day_list == perturbation_date(pi));
end

u_daily_target = u_daily(index,:,:);
v_daily_target = v_daily(index,:,:);
datenum_daily_target = datenum_list(index);

size_wind = [length(lat) length(lon)];
len_day_all =length(datenum_list);
len_day = length(datenum_daily_target);
len_wind = size_wind(1)*size_wind(2);

%% Detrend
u_state = u_daily_target(:,:);
u_state_detrend = detrend(u_state, 'linear');
u_detrend = reshape(u_state_detrend, [len_day size_wind]);

v_state = v_daily_target(:,:);
v_state_detrend = detrend(v_state, 'linear');
v_detrend = reshape(v_state_detrend, [len_day size_wind]);

%% Detrended average
u_mean_detrend = squeeze(nanmean(u_detrend));
v_mean_detrend = squeeze(nanmean(v_detrend));

%% Calculate average spatial standard deviation and Normalize the anomlies
u_mean_state = u_mean_detrend(:);
for di = 1:len_day
    deviation = squeeze(u_state_detrend(di,:))' - u_mean_state;
    variation = nanmean(deviation.^2);
    u_std(di,:) = sqrt(variation);
    u_final_state(di,:) = deviation./sqrt(variation);
end
u_final = reshape(u_final_state, [len_day size_wind]);

v_mean_state = v_mean_detrend(:);
for di = 1:len_day
    deviation = squeeze(v_state_detrend(di,:))' - v_mean_state;
    variation = nanmean(deviation.^2);
    v_std(di,:) = sqrt(variation);
    v_final_state(di,:) = deviation./sqrt(variation);
end
v_final = reshape(v_final_state, [len_day size_wind]);

%% Separate whole data into data points and NaN points
for di = 1:len_day % day index
    
    u_final_state = u_final(di,:);
    v_final_state = v_final(di,:);
    
    data_final(di,:) = [u_final_state v_final_state];
end

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
    
    for di = 1:len_day
        %% Make perturbation
        % random_number*sqrt(eigen value)*eigen vector
        for mi = 1:num_Mode % mode index
            Eigen_Vector = squeeze(u(:,mi));
            k_random_num = 0.1* (rand * (-1)^floor(rand*10));
            KLE_mode(mi,:) = k_random_num.*sq_Eigen_Value(mi).*Eigen_Vector;
        end
        KLE_sum = sum(KLE_mode);% Karhunen-Loeve expansion (KLE)
        
        u_KLE_state = KLE_sum(1:len_wind); KLE_sum(1:len_wind) = [];
        u_KLE = reshape(u_KLE_state, [size_wind]);
        
        v_KLE_state = KLE_sum(1:len_wind);
        v_KLE = reshape(v_KLE_state, [size_wind]);
        
        %% Make final data
        % Mean_data + KLE matrix
        final_u(di,:,:) = squeeze(u_daily_target(di,:,:)) + u_KLE;
        final_v(di,:,:) = squeeze(v_daily_target(di,:,:)) + v_KLE;
    end
    
    %% Make empty initial files and input data into the files
    ens_file_name = ['wind_ECMWF_ens', num2char(ei,3), '.nc'];
    create_empty_wind(ens_file_name, [len_day size_wind])
    nc = netcdf(ens_file_name, 'w');
    nc{'latitude'}(:) = lat; nc{'longitude'}(:) = lon;
    nc{'u10'}(:) = final_u; nc{'v10'}(:) = final_v;
    nc{'time'}(:) = datenum_daily_target;
    close(nc)
end