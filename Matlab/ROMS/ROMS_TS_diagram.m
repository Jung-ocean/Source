% using SEAWATER Tool box and Function making simple T-S plotting program 
% 2004-4-22, by Jeff Book (U.S. Naval Resarch Laboratory) and PETER
% m_file: TS_diagram2.m
% It need function file ('ts_plot_general.m'), and seawater toolbox

clc; clear; close all

fpath = '.\';
fname = 'monthly_201307.nc';
file = [fpath, fname];

box1_s = [34 34.2]; box1_t = [14 16];
box2_s = [33.5 34]; box2_t = [12 13];
box3_s = [30 35]; box3_t = [5 20];

nc = netcdf(file);
lon_rho = nc{'lon_rho'}(:); lat_rho = nc{'lat_rho'}(:);
lon_u = nc{'lon_u'}(:); lat_u = nc{'lat_u'}(:);
lon_v = nc{'lon_v'}(:); lat_v = nc{'lat_v'}(:);
angle = nc{'angle'}(:); ocean_time = nc{'ocean_time'}(:);
temp = nc{'temp'}(:); salt = nc{'salt'}(:);
mask_rho = nc{'mask_rho'}(:); mask_u = nc{'mask_u'}(:); mask_v = nc{'mask_v'}(:);
u = nc{'u'}(:); v = nc{'v'}(:);
close(nc)

ftime = datestr(datenum(2013, 01, 01, 00, 00, 00) + ocean_time/60/60/24, 'yyyy-mm-dd')
mask2 = mask_rho./mask_rho;


for i = 1:40
    temp_all(i,:,:) = squeeze(temp(i,:,:)).*mask2;
    salt_all(i,:,:) = squeeze(salt(i,:,:)).*mask2;
end

[lon_lim, lat_lim] = domain_J('KODC_small');

indexx = find(lon_rho(1,:) > lon_lim(1) & lon_rho(1,:) < lon_lim(2));
indexy = find(lat_rho(:,1) > lat_lim(1) & lat_rho(:,1) < lat_lim(2));

data_all = [];
for i = 1:length(indexy)
    %for ii = 1:length(indexx)

        temp_temp = temp_all(:, indexy(i), :);
        salt_temp = salt_all(:, indexy(i), :);
        
        data_all = [data_all; temp_temp(:) salt_temp(:)];
        
    %end
end

w(:,2) = data_all(:,1);
w(:,3) = data_all(:,2);

index = find(isnan(w(:,2)) == 1 & isnan(w(:,3)) == 1);
w(index,:) = [];

n = size(w,1);
x_lim = ([25 35]);
y_lim = ([0 30]);

% Call function 'ts_plot_general.m'
[c,h,x,y,dens_grid] = ts_plot_general(w,'r',x_lim,y_lim);
xlim([x_lim]); ylim([y_lim])
clabel(c)                          % Density 표시 
title(['T-S Diagram ', ftime], 'fontsize', 15)
set(gcf,'Color','w')               % 배경색 흰색

line([box1_s(1) box1_s(1) box1_s(2) box1_s(2) box1_s(1)], ...
    [box1_t(1) box1_t(2) box1_t(2) box1_t(1) box1_t(1)], 'color', [1 0.6 0], 'linewidth', 2)

line([box2_s(1) box2_s(1) box2_s(2) box2_s(2) box2_s(1)], ...
    [box2_t(1) box2_t(2) box2_t(2) box2_t(1) box2_t(1)], 'color', 'b', 'linewidth', 2)

line([box3_s(1) box3_s(1) box3_s(2) box3_s(2) box3_s(1)], ...
    [box3_t(1) box3_t(2) box3_t(2) box3_t(1) box3_t(1)], 'color', 'k', 'linewidth', 2)

saveas(gcf, 'TS_diagram.png')