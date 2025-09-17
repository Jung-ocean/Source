%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS temperature
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

exp = 'Dsm4';
vari_str = 'temp';
yyyy = 2022;
ystr = num2str(yyyy);
mm_all = 1:7;

timenum_all = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)));

isfill = 1;
layer = 45;
dstr = num2str(layer);

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');

% Figure properties
colormap = 'jet';
climit = [0 13];
interval = 1;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = '^oC';

savename = 'temp';

f1 = figure; hold on
set(gcf, 'Position', [1 200 800 500])
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

for ti = 1:length(timenum_all)
    
    timenum = timenum_all(ti);
    vari = load_BSf_3d_layer(g, vari_str, layer, timenum, isfill);
    p = plot_contourf([], g.lat_rho, g.lon_rho, vari, color, climit, contour_interval);
    plotm([62.1252 60.5932], [-185.1117 -182.7350], '--k', 'LineWidth', 2);

    if ti == 1
        c = colorbar;
        c.Title.String = unit;
    end

    if layer < 0
        title([num2str(-layer), 'm temperature (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15);
        if isfill == 1
            title([num2str(-layer), 'm or bottom temperature (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15);
        end
    elseif layer == 45
        title(['SST (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15);
    end

    % Make gif
    gifname = [savename, '_', map, '_layer_', dstr, '_', ystr, '_daily', '.gif'];

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