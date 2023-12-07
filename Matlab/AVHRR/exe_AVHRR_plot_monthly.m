clear; clc; close all

casename = 'YECS_large';

yyyy_all = 1988:1988
for yi = 1:length(yyyy_all)
    target_year = yyyy_all(yi);

for mi = 2:2
    target_month = mi;
    AVHRR_plot_monthly
    saveas(gcf, ['D:\Data\Satellite\AVHRR\AVHRR_', casename, '_', ystr, mstr, '.png'])
end

    %AVHRR_temp(yi,:,:) = temp_selected;

end

%save temp_AVHRR_Feb_1990_2001.mat AVHRR_temp Lat_selected Lon_selected yyyy_all