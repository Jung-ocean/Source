%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate EOF using satellite SSS products
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all;

polygon = [
 -182.5126   61.7660
 -181.5363   66.1555
 -157.1269   66.2215
 -157.4273   57.0464
 -165.3885   54.0431
  -182.5126   61.7660
];

sat = 'SMAP';
if strcmp(sat, 'SMAP')
    filepath = '/data/jungjih/Observations/Satellite_SSS/Global/RSS/v6.0/figures/SSSA/';
else
    filepath = '/data/jungjih/Observations/Satellite_SSS/Global/CEC/v9/figures/SSSA/';
end
yyyy_all = [2015:2023];
mm = 6;
mstr = num2str(mm, '%02i');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    load([sat, '_SSSA_', ystr, mstr, '.mat'])

    longitude = lon_sat;
    latitude = lat_sat;
    [lon2, lat2] = meshgrid(longitude, latitude);
    [in, on] = inpolygon(lon2, lat2, polygon(:,1), polygon(:,2));

    lon_target = lon2(in);
    lat_target = lat2(in);
    vari_sat_target = vari_sat(in);

    index_tmp = find(isnan(vari_sat_target) ~= 1);
    if yi == 1
        index = index_tmp;
    end

    common = find(ismember(index_tmp, index) == 1);
    index = index_tmp(common);
end

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    load([sat, '_SSSA_', ystr, mstr, '.mat'])

    longitude = lon_sat;
    latitude = lat_sat;
    [lon2, lat2] = meshgrid(longitude, latitude);
    [in, on] = inpolygon(lon2, lat2, polygon(:,1), polygon(:,2));

    lon_target = lon2(in);
    lat_target = lat2(in);
    vari_sat_target = vari_sat(in);

    SSS(yi,:) = vari_sat_target(index);
    lon_plot = lon_target(index);
    lat_plot = lat_target(index);
end

X = SSS'; % space x time

[M, N] = size(X);
R = X*X'/N; % Covariance matrix

[vec, val] = eig(R); % Eigen vector and value
eigen_val = sort(diag(val),'descend'); % Sorting
eigen_vec = zeros(size(vec));
for i = 1:length(val)
    index = find(diag(val) == eigen_val(i));
    eigen_vec(:,i) = vec(:,index);
end

percent = 100*(abs(eigen_val)/sum(eigen_val)); % Percentage
figure; hold on; grid on
plot(1:10,percent(1:10),'-ko','linewidth',2);
set(gca, 'xtick', [1:10])
ylim([0 100])
set(gca, 'FontSize', 15)
title('Percent of each mode')

Z = eigen_vec'*X; % Time
figure;
subplot(2,2,1); hold on; grid on; 
plot(yyyy_all, Z(1,:),'-ok'); title('Z', 'fontsize',15); legend('1 mode'); ylim([-50 50])
subplot(2,2,2); hold on; grid on; 
plot(yyyy_all, Z(2,:),'-ok'); title('Z', 'fontsize',15); legend('2 mode'); ylim([-50 50])
subplot(2,2,3); hold on; grid on; 
plot(yyyy_all, Z(3,:),'-ok'); title('Z', 'fontsize',15); legend('3 mode'); ylim([-50 50])
subplot(2,2,4); hold on; grid on; 
plot(yyyy_all, Z(4,:),'-ok'); title('Z', 'fontsize',15); legend('4 mode'); ylim([-50 50])

% figure; % Space
% subplot(2,2,1); plot(eigen_vec(:,1),'k'); title('Eigen vec','fontsize',15); legend('1 mode'); ylim([-0.5 0.5])
% subplot(2,2,2); plot(eigen_vec(:,2),'k'); title('Eigen vec','fontsize',15); legend('2 mode'); ylim([-0.5 0.5])
% subplot(2,2,3); plot(eigen_vec(:,3),'k'); title('Eigen vec','fontsize',15); legend('3 mode'); ylim([-0.5 0.5])
% subplot(2,2,4); plot(eigen_vec(:,4),'k'); title('Eigen vec','fontsize',15); legend('4 mode'); ylim([-0.5 0.5])

% Diagonal of L is eigen value
% L = eigen_vec'*R*eigen_vec;
% L_diag = diag(L);
% figure; plot(1:20,L_diag(1:20),'-ko','linewidth',2); title('Diagonal of L','fontsize',15)
% set(gca, 'xtick', [1:20])

X_1mode = eigen_vec(:,1)*Z(1,:); % X reconstruction using 1 mode
X_2mode = eigen_vec(:,2)*Z(2,:); % X reconstruction using 2 mode
X_3mode = eigen_vec(:,3)*Z(3,:); % X reconstruction using 3 mode
X_4mode = eigen_vec(:,4)*Z(4,:); % X reconstruction using 4 mode

X_mode = eigen_vec(:,1:2)*Z(1:2,:);

% Mode 1 ~ 4 space
figure;
for i = 1:4
    subplot(2,2,i)
    plot_map('Bering', 'mercator', 'l')

%     [Xi, Yi] = meshgrid(lon_plot, lat_plot);
%     Zi = griddata(lon_plot, lat_plot, eigen_vec(:,i), Xi, Yi);

    %pcolorm(Yi,Xi,Zi)
    scatterm(lat_plot, lon_plot, 10, eigen_vec(:,i))
    colormap redblue

    title(['Mode',num2str(i)],'fontsize',15, 'fontweight','bold')
    caxis([-0.1 0.1]) % pcolor range
end