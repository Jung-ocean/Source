%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS daily 
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy = 2024;
mm_all = 1:12;

vari_str = 'temp';
layer = 45;
casename = 'Oregon_1km';

iscontour = 0;
ispng = 0;
isgif = 1;

% Model
g = grd(casename);
mask = g.mask_rho./g.mask_rho;

switch vari_str
    case 'temp'
        dim = '3d';
        climit = [6 20];
        interval = 1;
        [color, contour_interval] = get_color('jet', climit, interval);
        unit = '^oC';

    case 'salt'
        dim = '3d';
        climit = [29 35];
        interval = 0.25;
        [color, contour_interval] = get_color('jet', climit, interval);
        unit = 'psu';

    case 'aice'
        dim = '2d';
        color = 'gray';
        climit = [0 1];
        unit = '';

    case 'zeta'
        dim = '2d';
        climit = [-1 1];
        interval = 0.1;
        [color, contour_interval] = get_color('jet', climit, interval);
        unit = 'm';
end

f1 = figure; hold on;
set(gcf, 'Position', [1 200 500 800])
plot_map('Oregon', 'mercator', 'l');
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

ystr = num2str(yyyy);

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mi, '%02i');

for di = 1:eomday(yyyy,mm)
    dd = di;
    timenum = datenum(yyyy,mm,dd);
    
    vari = load_models_2d_daily(casename, vari_str, layer, timenum);
    
    p = plot_contourf([], g.lat_rho, g.lon_rho, vari.*mask, color, climit, contour_interval);
    caxis(climit);
    colormap(color);
    c = colorbar;
    c.Title.String = unit;
    c.FontSize = 12;

    if iscontour == 1
        vari_contour = vari;
        vari_contour(isnan(vari_contour) == 1) = -10;
        [cs,h] = contourm(g.lat_rho, g.lon_rho, vari_contour, contour_interval, '-k', 'LineWidth', 4);
        cl = clabelm(cs, h, 'LabelSpacing', 500);
        set(cl, 'Color', 'k', 'FontSize', 20, 'LineStyle', 'none', 'BackgroundColor', 'none')
    end

    if strcmp(dim, '3d')
        title([vari_str, ' layer ', num2str(layer), ' (', datestr(timenum, 'yyyymmdd'), ')'], 'FontSize', 12)
    else
        title([vari_str, ' (', datestr(timenum, 'yyyymmdd'), ')'], 'FontSize', 12)
    end

%     % Argo location
%     load Argo_num_046.mat
%     index = find(floor(time) == timenum);
%     lon_point = lon(index);
%     lat_point = lat(index);
%     pt = plotm(lat_point, lon_point, '.k', 'MarkerSize', 15);

    if ispng == 1
        print([vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyymmdd')], '-dpng')
    end

    if isgif == 1
        % Make gif
        gifname = [vari_str, '_layer_', num2str(layer), '_', casename, '_', datestr(timenum, 'yyyy'), '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if mi == 1 && di == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end % ind_gif

    delete(p)
%     delete(pt)
    if iscontour == 1
        delete(cl); delete(h);
    end
end
end