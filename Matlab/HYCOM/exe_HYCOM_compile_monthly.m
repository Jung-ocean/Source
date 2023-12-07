clear; clc
for mm = 1:12
    clearvars -except mm
    HYCOM_compile_monthly 
end