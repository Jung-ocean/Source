clear; clc

yyyy = 2020; ystr = num2str(yyyy);

switch yyyy
    case 2018
        xlimit = [datenum(yyyy,4,1) datenum(yyyy,10,1)];
    case 2019
        xlimit = [datenum(yyyy,4,1) datenum(yyyy,10,1)];
    case 2020
        xlimit = [datenum(yyyy,4,1) datenum(yyyy,10,1)];
end

yyyy_all = 1980:2020;

filepath = 'D:\Data\River\';
filename = 'songjung_discharge_1980to2020\';

file = [filepath, filename];

load(file);

index = find(yyyy_all == yyyy);

discharge = cell2mat(dis_pre_total(index));
timenum = datenum(yyyy,1,1):datenum(yyyy,12,31);

xtick_list = [datenum(yyyy,1:12,1)];

figure; hold on; grid on
plot(timenum, discharge, 'LineWidth', 2);
set(gca, 'xtick', xtick_list);
datetick('x', 'mmm-dd', 'keepticks');
xlim(xlimit)
ylabel('m^3/s')

title([ystr, ' Sumjin discharge'])

set(gca, 'FontSize', 12)

saveas(gcf, ['sumjin_dischage_', ystr, '.png'])