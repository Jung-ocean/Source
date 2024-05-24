%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output seasonal averaged zeta with Satellite L2
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2018:2022;

month_all = {'JFM', 'AMJ', 'JAS', 'OND'};

JFM = 1:3;
AMJ = 4:6;
JAS = 7:9;
OND = 10:12;

isice = 0;
aice_value = 0.4;

switch vari_str
    case 'zeta'
        %climit_model = [-20 20];
        %climit_sat = climit_model;
        climit_model = [-30 10];
        climit_sat = [20 60];
        unit = 'cm';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/seasonal/'];

% Satellite SSH Merged L2
filepath_Merged = ['/data/jungjih/Observations/Satellite_SSH/Merged_MMv5.1_podaac/ADT_line_no_filter/'];
load([filepath_Merged, 'ADT_monthly.mat'])

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;

h1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(month_all)
        month_str = month_all{mi};
        month = eval(month_str);

        filename = [case_control, '_', ystr, '_', month_str, '.nc'];
        file = [filepath_control, filename];
        if ~exist(file)
            zeta = NaN;
        else
            zeta = mask.*ncread(file, 'zeta')';
        end
%         zeta = zeta - mean(zeta(:), 'omitnan');

        % Figure title
        title(t, [month_str, ', ', ystr], 'FontSize', 25);

        nexttile(1)
        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
        else
            delete(T(1));
        end

        T(1) = pcolorm(g.lat_rho,g.lon_rho,100*zeta);
        uistack(T(1),'bottom')
        caxis(climit_model)
        if yi == 1 && mi == 1
            c = colorbar;
            c.Title.String = unit;
            c.Ticks = climit_model(1):10:climit_model(end);
        end
        title(['ROMS'], 'Interpreter', 'None')

        % Satellite
        index = find(timevec_all(:,1) == yyyy & ismember(timevec_all(:,2), month) == 1);

        adt = mean(ADT_monthly(index,:));
%         adt = adt - mean(adt, 'omitnan');

        % Tile
        nexttile(2);

        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k');
        else
            delete(T(2));
        end
        T(2) = scatterm(lat_ref, lon_ref, 400, 100*adt, '.');

        uistack(T(2),'bottom')
        caxis(climit_sat)
        if yi == 1 && mi == 1
            c = colorbar;
            c.Title.String = unit;
            c.Ticks = climit_sat(1):10:climit_sat(end);
        end

%         title('MERGED_TP_J1_OSTM_OST_CYCLES_V51', 'Interpreter', 'None')
        title('Satellite L2', 'Interpreter', 'None')

        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        pause(1)
        print(['compare_', vari_str, '_L2_seasonal_', ystr, '_', num2str(mi, '%02i'), '_', month_str],'-dpng');

        % Make gif
        gifname = ['compare_', vari_str, '_L2_seasonal.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if yi == 1 && mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

    end % mi
end % yi