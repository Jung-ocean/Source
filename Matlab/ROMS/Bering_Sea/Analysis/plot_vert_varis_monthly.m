%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta, temperature, salinity, potential density and velocity 
% vertical section
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

model = 'NANOOS';
yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

% Load grid information
g = grd('NANOOS');

Trans_label = 'Columbia_River';
ismap = 0;

switch Trans_label
    case 'Koryak_coast'
        domaxis = [-185.1117 -182.7350 62.1252 60.5932];
        ylimit = [-500 0];
    case 'Cape_Navarin'
        domaxis = [-181.1100 -178.7333 62.7941 61.2621];
        ylimit = [-200 0];
    case 'Gulf_of_Anadyr'
        domaxis = [-180.1 -173.5 65 61.5];
        ylimit = [-100 0];
        FS = 10;
        TFS = 12;
    case 'Columbia_River'
        map = 'US_west';
        domaxis = [-124.6394 -123.95 45.9946 45.9946];
        hcontours = [200 200];
        ylimit = [-200 0];
        xlabels = 'Longitude (^oE)';
        FS = 10;
        TFS = 12;

        temp_limit = [5 18];
        temp_interval = 1;
        salt_limit = [29 34.5];
        salt_interval = 0.25;
        pden_limit = [20 27];
        pden_interval = 0.5;
end

if ismap == 1
    figure; 
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, hcontours, 'k');
    plotm([domaxis(3:4)], [domaxis(1:2)], '-r', 'LineWidth', 2)
    print(['line_', Trans_label], '-dpng')
end

savename = 'varis';

f1 = figure; hold on
t = tiledlayout(3,1);
t.TileSpacing = 'compact';
t.Padding = 'compact';
set(gcf, 'Position', [1 200 600 900])

for mi = 1:length(mm_all)
    
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');
    timenum = datenum(yyyy,mm,15);
    title(t, datestr(timenum, 'mmm, yyyy'), 'FontSize', 15)

    % Temperature
    [x, Yi, data] = load_models_vertical_monthly(model, g, 'temp', yyyy, mm, domaxis);
    
    % Figure properties
    [color, contour_interval] = get_color('jet', temp_limit, temp_interval);
    unit = '^oC';

    ax1 = nexttile(1);
    p1 = plot_contourf([], x, Yi, data, color, temp_limit, contour_interval);
    xlim([domaxis(1) domaxis(2)])
    xticklabels('');
    ylim(ylimit)
    ylabel('Depth (m)');
    set(gca, 'FontSize', FS)
    c = colorbar;
    c.Title.String = unit;
    c.Ticks = [temp_limit(1):temp_interval*2:temp_limit(2)];
    title(['Temperature (interval = ', num2str(temp_interval), ' ', unit, ')'], 'FontSize', TFS);

    % Salinity
    [x, Yi, data] = load_models_vertical_monthly(model, g, 'salt', yyyy, mm, domaxis);

    % Figure properties
    [color, contour_interval] = get_color('jet', salt_limit, salt_interval);
    unit = 'psu';

    ax2 = nexttile(2);
    p2 = plot_contourf([], x, Yi, data, color, salt_limit, contour_interval);
    xlim([domaxis(1) domaxis(2)])
    xticklabels('');
    ylim(ylimit)
    ylabel('Depth (m)');
    set(gca, 'FontSize', FS)
    c = colorbar;
    c.Title.String = unit;
    c.Ticks = [salt_limit(1):salt_interval*2:salt_limit(2)];
    title(['Salinity (interval = ', num2str(salt_interval), ' ', unit, ')'], 'FontSize', TFS);

    % Potential density
    [x, Yi, data] = load_models_vertical_monthly(model, g, 'pden', yyyy, mm, domaxis);
    data = data - 1000;

    % Figure properties
    [color, contour_interval] = get_color('jet', pden_limit, pden_interval);
    unit = '\sigma_\theta';

    ax3 = nexttile(3);
    p3 = plot_contourf([], x, Yi, data, color, pden_limit, contour_interval);
    xlim([domaxis(1) domaxis(2)])
    xlabel(xlabels);
%     xticklabels('');
    ylim(ylimit)
    ylabel('Depth (m)');
    set(gca, 'FontSize', FS)
    c = colorbar;
    c.Title.String = unit;
    c.Ticks = [pden_limit(1):pden_interval*2:pden_limit(2)];
    title(['Potential density (interval = ', num2str(pden_interval), ' ', unit, ')'], 'FontSize', TFS);

%     % Normal velocity
%     [x, Yi, data] = load_BSf_vertical_monthly(g, 'v_n', yyyy, mm, domaxis);
%     data = data.*100; % m/s to cm/s
% 
%     % Figure properties
%     colormap = 'redblue';
%     climit = [-15 15];
%     interval = 3;
%     [color, contour_interval] = get_color(colormap, climit, interval);
%     unit = 'cm/s';
% 
%     ax5 = nexttile(5);
%     p5 = plot_contourf([], x, Yi, data, color, climit, contour_interval);
%     xlim([domaxis(1) domaxis(2)])
%     xlabel('Longitude');
%     ylim(ylimit)
%     ylabel('Depth (m)');
%     set(gca, 'FontSize', FS)
%     c = colorbar;
%     c.Title.String = unit;
%     c.Ticks = [climit(1):interval*2:climit(2)];
%     title(['Normal velocity (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', TFS);
    pause(3)
    print(['vert_varis_', ystr, mstr], '-dpng')
    
    delete(p1)
    delete(p2)
    delete(p3)
end