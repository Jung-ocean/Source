%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output seasonally averaged zeta with Satellite
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2018:2020;

month_all = {'JFM', 'AMJ', 'JAS', 'OND'};

JFM = 1:3;
AMJ = 4:6;
JAS = 7:9;
OND = 10:12;

isice = 0;
aice_value = 0.4;

switch vari_str
    case 'zeta'
        climit_model = [-40 20];
        climit_sat = [10 70];
        unit = 'cm';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/seasonally/'];

% Satellite SSH Merged L2
filepath_Merged = ['/data/jungjih/Observations/Satellite_SSH/Merged_MMv5.1_podaac/ADT_line_no_filter/'];
load([filepath_Merged, 'ADT_monthly.mat'])

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

for mi = 1:length(month_all)
    month_str = month_all{mi};
    month = eval(month_str);

    filename = [case_control, '_', month_str, '.nc'];
    file = [filepath_control, filename];
    zeta = ncread(file, 'zeta')';

    % Figure
    if mi == 1
        h1 = figure; hold on;
        set(gcf, 'Position', [1 200 1800 650])
        t = tiledlayout(1,2);
    else
        delete(ttitle);
    end

    % Figure title
    ttitle = annotation('textbox', [.44 .85 .20 .15], 'String', [month_str, ', ', num2str(yyyy_all(1)), '-', num2str(yyyy_all(end))]);
    ttitle.FontSize = 25;
    ttitle.EdgeColor = 'None';

    nexttile(1)
    if mi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
    else
        delete(T(1));
    end

    T(1) = pcolorm(g.lat_rho,g.lon_rho,100*zeta.*mask);
    uistack(T(1),'bottom')
    caxis(climit_model)
    if mi == 1
        c = colorbar;
        c.Title.String = unit;
    end
    title(['ROMS ', case_control], 'Interpreter', 'None')

    % Satellite
    adt = mean(ADT_monthly(month,:));

    % Tile
    nexttile(2);

    if mi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
    else
        delete(T(2));
    end
    T(2) = scatterm(lat_ref, lon_ref, 200, 100*adt, '.');

    uistack(T(2),'bottom')
    caxis(climit_sat)
    if mi == 1
        c = colorbar;
        c.Title.String = unit;
    end

    title('MERGED_TP_J1_OSTM_OST_CYCLES_V51', 'Interpreter', 'None')

    pause(1)
    %     print(strcat('compare_surface_', vari_str, '_satellite_monthly_', datestr(timenum, 'yyyymm')),'-dpng');

    % Make gif
    gifname = ['compare_', vari_str, '_L2_seasonally.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if mi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

end % mi
