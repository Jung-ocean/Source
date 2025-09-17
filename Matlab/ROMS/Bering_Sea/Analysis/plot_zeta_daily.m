%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS zeta
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

exp = 'Dsm4';
vari_str = 'zeta';
yyyy = 2020;
ystr = num2str(yyyy);
mm_all = 1:6;

timenum_all = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)));


filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');

% Figure properties
colormap = 'jet';
climit = [-40 40];
interval = 2.5;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'cm';

savename = 'zeta';

f1 = figure; hold on
set(gcf, 'Position', [1 200 800 500])
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

for ti = 1:length(timenum_all)
    
    timenum = timenum_all(ti);
    vari = 100*load_BSf_2d_daily(g, vari_str, timenum);
    p = plot_contourf([], g.lat_rho, g.lon_rho, vari, color, climit, contour_interval);
    plotm([62.1252 60.5932], [-185.1117 -182.7350], '--k', 'LineWidth', 2);

    if ti == 1
        c = colorbar;
        c.Title.String = unit;
    end

    title(['Sea level (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15);
  
    % Make gif
    gifname = [savename, '_', map, '_', ystr, '_daily', '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(p)
end