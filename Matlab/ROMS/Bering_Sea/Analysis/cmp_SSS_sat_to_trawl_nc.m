%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare sats SSS to bottom trawl survey salinity
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Trawl';
vari_str = 'SSS';
yyyy_all = [2021:2021];

g = grd('BSf');

% Figure properties
vari_roms = 'salt';
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color('jet', climit, interval);
unit = 'psu';

climit2 = [-2 2];
interval2 = 0.5;
[color2, contour_interval2] = get_color('redblue', climit2, interval2);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); 
    ystr = num2str(yyyy);

    load(['SSS_SMAP_trawl_', ystr, '.mat']);

    k = boundary(lon_obs,lat_obs,1);
    [in, on] = inpolygon(lon_obs2, lat_obs2, lon_obs(k), lat_obs(k));
    mask = in./in;

    % Plot
    f1 = figure;
    set(gcf, 'Position', [1 200 1500 800])
    t = tiledlayout(2,4);
    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    ax1 = nexttile(1);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    pobs = plot_contourf(ax1, lat_obs2, lon_obs2, vari_obs2.*mask, color, climit, contour_interval);
    title(['Trawl survey ', vari_str], 'FontSize', 15)
    plabel('FontSize', 12)
    mlabel('FontSize', 12)

    textm(56.3, -179.5, datestr(min(timenum), 'yyyy'), 'FontSize', 25)
    textm(55, -179.5, [datestr(min(timenum), 'mm/dd'), '-', datestr(max(timenum), 'mm/dd')], 'FontSize', 18);

    % SMAP plot
    ax2 = nexttile(2);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax2, lat_sat2, lon_sat2, vari_sat2.*mask, color, climit, contour_interval);
    title('RSS SMAP SSS', 'FontSize', 15)
    plabel('off')
    mlabel('off')

    ax6 = nexttile(6);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax6, lat_sat2, lon_sat2, (vari_sat2-vari_obs2).*mask, color2, climit2, contour_interval2);
    title('Difference', 'FontSize', 15)
    plabel('FontSize', 12)
    mlabel('FontSize', 12)

    % SMOS plot
    load(['SSS_SMOS_trawl_', ystr, '.mat']);

    ax3 = nexttile(3);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax3, lat_sat2, lon_sat2, vari_sat2.*mask, color, climit, contour_interval);
    title('CEC SMOS SSS', 'FontSize', 15)
    plabel('off')
    mlabel('off')

    ax7 = nexttile(7);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax7, lat_sat2, lon_sat2, (vari_sat2-vari_obs2).*mask, color2, climit2, contour_interval2);
    title('Difference', 'FontSize', 15)
    plabel('off');
    mlabel('FontSize', 12)
    
    % SMOS BEC plot
    load(['SSS_SMOS_BEC_trawl_', ystr, '.mat']);

    ax4 = nexttile(4);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax4, lat_sat2, lon_sat2, vari_sat2.*mask, color, climit, contour_interval);
    title('BEC SMOS SSS', 'FontSize', 15)
    plabel('off')
    mlabel('off')
    
    c1 = colorbar;
    c1.Title.String = unit;
    c1.FontSize = 12;

    ax8 = nexttile(8);
    plot_map(map, 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
    psat = plot_contourf(ax8, lat_sat2, lon_sat2, (vari_sat2-vari_obs2).*mask, color2, climit2, contour_interval2);
    title('Difference', 'FontSize', 15)
    plabel('off')
    mlabel('FontSize', 12)

    c2 = colorbar;
    c2.Title.String = unit;
    c2.FontSize = 12;
    
    c2Position = c2.Position;
    c2Position(1) = .2;
    c2Position(2) = 0.03;
    c2Position(3) = .02;
    c2.Position = c2Position;

    c1Position = c1.Position;
    c1Position(1) = .1;
    c1Position(2) = c2Position(2);
    c1Position(3) = 0.02;
    c1.Position = c1Position;

asdf
    print(['cmp_sats_', vari_str, '_w_trawl_', ystr], '-dpng')
end

