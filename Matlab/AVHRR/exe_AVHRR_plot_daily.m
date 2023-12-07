clear; clc; close all

target_year = 2003;
target_month = 6;
casename = 'Taean';

for di = 15:15
    target_day = di;
    AVHRR_plot_daily
    saveas(gcf, ['AVHRR_', tys, tms, tds, '_', casename, '.png'])
end