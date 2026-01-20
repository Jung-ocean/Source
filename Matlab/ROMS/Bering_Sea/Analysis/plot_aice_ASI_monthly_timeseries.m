%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ASI aice monthly timeseries
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr';
mm = 6;
mstr = num2str(mm, '%02i');
mstr_title = datestr(datenum(0,mm,1), 'mmm');

load(['Fi_ASI_', region, '_', mstr, '.mat']);

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot(timenum, Fi, '-ko', 'LineWidth', 2);
xticks(timenum)
if mm == 5
    yticks([0:0.1:1])
else
    yticks([0:0.05:1])
end
datetick('x', 'yy', 'keepticks', 'keeplimits');
xtickangle(0);
xlabel('Year')
set(gca, 'FontSize', 15)

title(['Area-averaged sea ice fraction in ', mstr_title])

print(['aice_ASI_', region, '_', mstr], '-dpng')