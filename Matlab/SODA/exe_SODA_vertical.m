clear; clc; close all;

filepath = 'd:\Data\Ocean\Model\SODA\';
namelist = dir([filepath, '*.cdf']);


for i = 1:length(namelist)
    filename = namelist(i).name
    SODA_vertical
    
    saveas(gcf, ['vertical_', vertical_dir, '_', num2str(target_Loc), '_', target_value, '_', filename(1:end-4), '.png'])
end