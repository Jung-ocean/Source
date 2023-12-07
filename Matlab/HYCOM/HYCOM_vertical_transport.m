%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Calculate HYCOM transport (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filepath = 'd:\Data\Ocean\Model\HYCOM\GLBa0.08_expt90.8_monthly\';
namelist = dir([filepath, '*.nc']);

target_value = 'u';
vertical_dir = 'Meridional';
target_Loc = 161.12;
xlimits = [46 51]; % Latitude or Longitude
ylimits = [-1 5600]; % depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trans_monthly = [];
for i = 1:length(namelist)
    
    filename = namelist(i).name;
    file = [filepath, filename];
    
    ncload(file)
    
    value = eval(target_value);
    
    layer_thickness = diff(depth);
    layer_thickness(end+1) = layer_thickness(end);
    
    yind = find(depth > ylimits(1) & depth < ylimits(2));
    
    if strcmp(vertical_dir, 'Meridional')
        Loc = longitude(1,:);
        xaxis = latitude(:,1);
        xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
        xaxis = xaxis(xind);
        
        dist = (target_Loc - Loc).^2;
        di = find(dist == min(dist));
        value_vertical = squeeze(value(yind,xind,di(1)));
        
        dl = mean(diff(xaxis))*111000;
        
    elseif strcmp(vertical_dir, 'Zonal')
        Loc = lat(:,1);
        xaxis = lon(1,:);
        xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
        xaxis = xaxis(xind);
        
        dist = (target_Loc - Loc).^2;
        di = find(dist == min(dist));
        value_vertical = squeeze(value(yind,di(1),xind));
        
        dl = mean(diff(xaxis)) * 111000*cos(target_Loc*pi/180);
        
    end
    
    trans_sum = zeros;
    for li = 1:length(xind)
        trans = nansum(dl*layer_thickness.*value_vertical(:,li))./(10^6);
        trans_sum = trans_sum + trans;
    end
    
    trans_monthly = [trans_monthly; trans_sum];
    
end

figure;
plot(trans_monthly, 'o-', 'linewidth', 2)
grid on
set(gca,'FontSize', 15)
ylabel('Sv', 'FontSize', 15)
xlabel('Month', 'FontSize', 15)