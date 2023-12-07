%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Calculate SODA transport (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filepath = 'd:\Data\Ocean\Model\SODA\';
namelist = dir([filepath, '*.cdf']);

target_value = 'U';
vertical_dir = 'Meridional';
target_Loc = 161.12;
xlimits = [48.5 50]; % Latitude or Longitude
ylimits = [0 5500]; % depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trans_monthly = [];
for i = 1:length(namelist)
    
    filename = namelist(i).name;
    file = [filepath, filename];
    
    ncload(file)
    
    value = eval(target_value);
    value(value < -1000) = NaN;
    
    layer_thickness = diff(DEPTH_bnds, 1, 2);
    
    yind = find(DEPTH > ylimits(1) & DEPTH < ylimits(2));
    
    if strcmp(vertical_dir, 'Meridional')
        Loc = LON;
        xaxis = LAT;
        xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
        xaxis = LAT(xind);
        
        dist = (target_Loc - Loc).^2;
        di = find(dist == min(dist));
        value_vertical = squeeze(value(yind,xind,di(1)));
        
        dl = (LAT(2) - LAT(1))*111000;
        
    elseif strcmp(vertical_dir, 'Zonal')
        Loc = LAT;
        xaxis = LON;
        xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
        xaxis = LON(xind);
        
        dist = (target_Loc - Loc).^2;
        di = find(dist == min(dist));
        value_vertical = squeeze(value(yind,di(1),xind));
        
        dl = (LON(2) - LON(1)) * 111000*cos(target_Loc*pi/180);
        
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