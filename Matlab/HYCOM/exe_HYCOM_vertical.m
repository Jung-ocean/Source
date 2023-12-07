clear; clc; close all;

filepath = 'D:\Data\Ocean\Model\HYCOM\GLBa0.08_expt90.8_monthly\';
namelist = dir([filepath, '*.nc']);


for i = 1:length(namelist)
    filename = namelist(i).name
    HYCOM_vertical
    
    saveas(gcf, ['vertical_', vertical_dir, '_', num2str(target_Loc), '_', target_value, '_', filename(1:end-3), '.png'])
end