%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Merged_MMv5.1_podaac seasonal using .mat file
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'adt'; % adt or ssha

month_all = {'JFM', 'JAS'};

JFM = 1:3;
JAS = 7:9;

load('ADT_monthly.mat')

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;
%

switch vari_str
    case 'adt'
        climit = [10 70];
        title_header = 'Absolute dynamic topography';
        gifname_header = 'ADT';

    case 'ssha'
        climit = [-0.2 0.2];
        title_header = 'Sea level anomaly';
        gifname_header = 'SLA';
end

h1 = figure; hold on
plot_map('Bering', 'mercator', 'l');
[C,h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', 'k');
% cl = clabelm(C,h); set(cl, 'BackgroundColor', 'none');
set(gcf, 'Position', [1 1 1300 800])

for mi = 1:length(month_all)
    month_str = month_all{mi};
    month = eval(month_str);

    adt = mean(ADT_monthly(month,:));
    
    if exist('s', 'var') == 1
        delete(s)
    end
    s = scatterm(lat_ref, lon_ref, 200, 100*adt, '.');
    caxis(climit)
    c = colorbar;
    c.Title.String = 'cm';

    title([title_header, ' (', month_str, ', ', '2018-2020)'])

    print(['ADT_monthly_', month_str], '-dpng')
end