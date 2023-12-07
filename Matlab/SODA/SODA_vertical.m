%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Plot SODA vertical section (Monthly)
%       J. JUNG
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear; clc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%filepath = 'd:\Data\Ocean\Model\SODA\';
%filename = 'SODA_2.2.4_201001.cdf';
file = [filepath, filename];

target_value = 'U';
vertical_dir = 'Meridional';
target_Loc = 161.12;
xlimits = [46 51];
ylimits = [0 2000];
climits = [-0.3 0.3];
clabel_name = 'm/s';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ncload(file)

value = eval(target_value);
value(value < -1000) = NaN;

yind = find(DEPTH > ylimits(1) & DEPTH < ylimits(2));
yaxis = DEPTH(yind);

if strcmp(vertical_dir, 'Meridional')
    Loc = LON;
    xaxis = LAT;
    xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
    xaxis = LAT(xind);
    
    dist = (target_Loc - Loc).^2;
    di = find(dist == min(dist));
    Loc_ind = Loc(di(1));
    value_vertical = squeeze(value(yind,xind,di(1)));
    xlabel_name = 'Latitude';
    
elseif strcmp(vertical_dir, 'Zonal')
    Loc = LAT;
    xaxis = LON;
    xind = find(xaxis > xlimits(1) & xaxis < xlimits(2));
    xaxis = LON(xind);
    
    dist = (target_Loc - Loc).^2;
    di = find(dist == min(dist));
    Loc_ind = Loc(di(1));
    value_vertical = squeeze(value(yind,di(1),xind));
    xlabel_name = 'Longitude';
    
end

[xx, yy] = meshgrid(xaxis, yaxis);

figure; pcolor(xx, yy, value_vertical); shading flat
axis ij;
xlabel(xlabel_name, 'FontSize', 15)
ylabel('Depth', 'FontSize', 15)
set(gca, 'FontSize', 15)
h = colorbar; h.Label.String = clabel_name;
colormap redblue; caxis(climits)
title([vertical_dir, ' section ', num2str(target_Loc), ' ', target_value, ' ', filename(12:end-4)], 'FontSize', 15)
