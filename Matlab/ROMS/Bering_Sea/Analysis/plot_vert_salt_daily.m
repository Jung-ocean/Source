%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS salinity vertical section
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
vari_str = 'salt';
yyyy = 2020;
ystr = num2str(yyyy);
mm_all = 1:6;

timenum_all = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)));

Trans_label = 'Koryak_coast';
domaxis = [-185.1117 -182.7350 62.1252 60.5932];
ylimit = [-500 0];

% Trans_label = 'Cape_Navarin';
% domaxis = [-181.1100 -178.7333 62.7941 61.2621];
% ylimit = [-200 0];

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');

% Figure properties
colormap = 'jet';
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'psu';

savename = 'salt';

f1 = figure; hold on
t = tiledlayout(3,1);
t.TileSpacing = 'compact';
t.Padding = 'compact';
set(gcf, 'Position', [1 200 800 800])

for ti = 1:length(timenum_all)
    
    timenum = timenum_all(ti);
    title(t, datestr(timenum, 'mmm dd, yyyy'))

    [x, Yi, data] = load_BSf_vertical(g, vari_str, timenum, domaxis);
    [x2, zeta_data] = load_BSf_line_2d(g, 'zeta', timenum, domaxis);

    ax1 = nexttile(1); hold on; grid on;
    p1 = plot(x2, zeta_data*100, '-k', 'LineWidth', 2);
    xlim([min(x2) max(x2)])
    ylim([-40 40]);
    xticks(unique(floor(x2)));
    ylabel('cm');
    xticklabels('')
    set(gca, 'FontSize', 12)
    title('Sea level', 'FontSize', 15)

    ax2 = nexttile(2,[2 1]);
    p2 = plot_contourf([], x, Yi, data, color, climit, contour_interval);
    xlim([min(x(:,1)) max(x(:,1))])
    ylim(ylimit)
    xticks(unique(floor(x(:,1))));
    xlabel('Longitude');
    ylabel('Depth (m)');
    set(gca, 'FontSize', 12)
    c = colorbar;
    c.Title.String = unit;
  
    title(['Salinity'], 'FontSize', 15);

    % Make gif
    gifname = ['vert_', savename, '_', Trans_label, '_', ystr, '_daily', '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
    
    delete(p1)
    delete(p2)
end