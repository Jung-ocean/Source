%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Perturb ECMWF Tair using Karhunen-Loeve expansion (EOF)
%       J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc

%% Setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
yyyy = 2016; tys = num2str(yyyy);
start_datenum = datenum(yyyy,1,1,0,0,0);
end_datenum = datenum(yyyy,12,31,18,0,0);

% The number of ensemble and the number of mode
num_Ensemble = 31;
num_Mode = 5; % usually 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perturbation_date = str2num(datestr(start_datenum:end_datenum, 'yyyymmddHH'));

disp('Perturbing Tair forcing using Karhunen_Loeve expansion'); disp(' ');
disp(['The number of ensemble = ', num2str(num_Ensemble)])

%% File
filepath = 'D:\Data\Atmosphere\ECMWF_interim\';
filename = [tys, '-1.nc'];
file = [filepath, filename];

%% Read netcdf file
nc = netcdf(file);
Tair = nc{'t2m'}(:); 
Tair_scale_factor = nc{'t2m'}.scale_factor(:); Tair_add_offset = nc{'t2m'}.add_offset(:);
lat = nc{'latitude'}(:); lon = nc{'longitude'}(:); [xx,yy] = meshgrid(lon,lat);
time = nc{'time'}(:);
close(nc)

Tair = Tair.*Tair_scale_factor + Tair_add_offset;
date = datestr(time/24 + datenum(1900,01,01), 'yyyymmddHH');

%% Arrange date
Tair_datenum = datenum(date, 'yyyymmddHH');
datenum_list = unique(Tair_datenum);
day_list = str2num(datestr(datenum_list, 'yyyymmddHH'));

Tair_target = Tair;
datenum_target = datenum_list;

size_Tair = [length(lat) length(lon)];
len_day = length(datenum_target);
len_Tair = size_Tair(1)*size_Tair(2);

%% Detrend
Tair_state = Tair_target(:,:);
Tair_state_detrend = detrend(Tair_state, 'linear');
Tair_detrend = reshape(Tair_state_detrend, [len_day size_Tair]);

%% Detrended average
Tair_mean_detrend = squeeze(nanmean(Tair_detrend));

%% Calculate average spatial standard deviation and Normalize the anomlies
Tair_mean_state = Tair_mean_detrend(:);
for di = 1:len_day
    deviation = squeeze(Tair_state_detrend(di,:))' - Tair_mean_state;
    variation = nanmean(deviation.^2);
    Tair_std(di,:) = sqrt(variation);
    Tair_final_state(di,:) = deviation./sqrt(variation);
end
Tair_final = reshape(Tair_final_state, [len_day size_Tair]);

%% Separate whole data into data points and NaN points
for di = 1:len_day % day index
    
    Tair_final_state = Tair_final(di,:);
        
    data_final(di,:) = [Tair_final_state];
end

%% EOF analysis
[m ,n] = size(data_final);
[u, s, v] = svds(data_final', num_Mode);

Eigen_Value = diag(s.^2);
sq_Eigen_Value = sqrt(Eigen_Value);

% Squared covariance fraction (SCF)
scf = Eigen_Value./sum(Eigen_Value);

load random_Number_0.1_Tair.mat
%% Ensemble loop
for ei = 1:num_Ensemble % ensemble index
    disp(['Ensemble number ', num2str(ei), '/', num2str(num_Ensemble)])
    
    for di = 1:len_day
        %% Make perturbation
        % random_number*sqrt(eigen value)*eigen vector
        for mi = 1:num_Mode % mode index
            Eigen_Vector = squeeze(u(:,mi));
            %k_random_num = 0.1* (rand * (-1)^floor(rand*10));
            %KLE_mode(mi,:) = k_random_num.*sq_Eigen_Value(mi).*Eigen_Vector;
            KLE_mode(mi,:) = random_Number(ei,mi).*sq_Eigen_Value(mi).*Eigen_Vector;
        end
        KLE_sum = sum(KLE_mode);% Karhunen-Loeve expansion (KLE)
        
        Tair_KLE_state = KLE_sum(1:len_Tair); KLE_sum(1:len_Tair) = [];
        Tair_KLE = reshape(Tair_KLE_state, [size_Tair]);
        
        %% Make final data
        % Mean_data + KLE matrix
        final_Tair(di,:,:) = squeeze(Tair_target(di,:,:)) + Tair_KLE;
    end
    
    %% Make empty initial files and input data into the files
    ens_file_name = ['Tair_ECMWF_', tys,'_ens', num2char(ei+1,2), '.nc'];
    create_empty_Tair(ens_file_name, [len_day size_Tair])
    nc = netcdf(ens_file_name, 'w');
    nc{'latitude'}(:) = lat; nc{'longitude'}(:) = lon;
    nc{'t2m'}(:) = final_Tair;
    nc{'time'}(:) = datenum_target;
    close(nc)
end