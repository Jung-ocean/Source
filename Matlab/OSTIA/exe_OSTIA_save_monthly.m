clear; clc

for i = 1:12
    clearvars -except i
    target_year = 2020;
    target_month = i;
    OSTIA_save_monthly
end