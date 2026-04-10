%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS monthly SSS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4_mk2';
region = 'Bering';

% Load grid information
g = grd('BSf');

vari_str = 'salt';
yyyy = 9999;
mm_all = 1:12;

if yyyy == 9999
    ystr = 'climate';
    entire_title_str = ['Multi-year mean SSS (2019-2023)'];
else
    ystr = num2str(yyyy);
end

colormap = 'jet';
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'psu';

figure;
if strcmp(region, 'NE_Pacific')
    set(gcf, 'Position', [1 200 1900 450])
else
    set(gcf, 'Position', [1 200 1800 900])
end
t = tiledlayout(3,4);
t.Padding = 'compact';
t.TileSpacing = 'tight';

title(t, [entire_title_str], 'FontSize', 20);

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    title_str = datestr(datenum(yyyy,mm,1), 'mmm');

    nexttile(mi); hold on
    plot_map(region, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

    vari = load_models_2d_monthly(exp, vari_str, g.N, yyyy, mm);
    plot_contourf([], g.lat_rho, g.lon_rho, vari, color, climit, contour_interval);

    if mi == 1
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
        c.FontSize = 15;
    end

    if strcmp(region, 'Gulf_of_Anadyr')
        t1 = textm(text1_lat, text1_lon, 'ERA5', 'FontSize', text_FS);
        t2 = textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS);
    else
        title([title_str], 'FontSize', 15)
    end

    if mi < 9
        mlabel('off')
    end
    if ~ismember(mi, [1 5 9])
        plabel('off')
    end
end % mi

print(['SSS_', region, '_', ystr, '_monthly'],'-dpng');