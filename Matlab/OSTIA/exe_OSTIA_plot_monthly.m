clear; clc; close all

yyyy = 2019;
mm_all = 1:12;

casename = 'NWP';
domain_case = casename;

switch casename
    case 'NP'
        cinterval = 4;
    case 'NWP'
        cinterval = 4;
end

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    
    if yyyy < 2014
        OSTIA_plot_monthly_mat
    else
        OSTIA_plot_monthly_nc
    end
    saveas(gcf, ['OSTIA_', casename, '_', ystr, mstr, '.png'])
end