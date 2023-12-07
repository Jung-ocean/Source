clear; clc; close all;

yi = 2001;
casename = 'NWP';
domain_case = 'YECS_small';

for mi = 1:12
    clearvars -except mi yi casename domain_case
    ROMS_plot_monthly_nc
end

domain_case = 'NWP';

for mi = 1:12
    clearvars -except mi yi casename domain_case
    ROMS_plot_monthly_nc
end

close all;

for yi = 2002:2016
    filepath = ['G:\Model\ROMS\Case\NWP\output\exp_HYCOM\', num2char(yi,4), '\'];
    cd(filepath)
    
    casename = 'NWP';
    domain_case = 'YECS_small';
    
    for mi = 1:12
        clearvars -except mi yi casename domain_case
        ROMS_plot_monthly_nc
    end
    close all;
    
    
    domain_case = 'NWP';
    
    for mi = 1:12
        clearvars -except mi yi casename domain_case
        ROMS_plot_monthly_nc
    end
    close all;
    
end