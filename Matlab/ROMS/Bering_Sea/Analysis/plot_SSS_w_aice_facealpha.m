%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SSS (ROMS) with ice concentration (ROMS)
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
map = 'Bering';
startdate = datenum(2018,7,1);

yyyy = 2021;
ystr = num2str(yyyy);
timenum_start = datenum(yyyy,1,1);
timenum_end = datenum(yyyy,7,31);

g = grd('BSf');

% Figure properties
interval = 0.25;
climit = [29 34];
[color, contour_interval] = get_color('jet', climit, interval);
unit = ['psu'];
savename = 'SSS_w_aice_facealpha';

f1 = figure;
set(gcf, 'Position', [1 200 800 500])
plot_map(map, 'eqaconic', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');
ax = gca;
set(gca,...
    'XColor','none',...
    'YColor','none')
set(gcf,'color','w')

% Common area plot
load /data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/SSS/Gulf_of_Anadyr_common/mask_common_07_01.mat
dx = 1./g.pm; dy = 1./g.pn;
mask = (mask_common./mask_common);
area = dx.*dy.*mask;
mask_map = mask;
mask_map(isnan(mask_map) == 1) = 0;

isfirst = 1;
for ti = timenum_start:timenum_end

    timenum = ti;
    title_str = datestr(timenum, 'mmm dd, yyyy');
    title([title_str], 'FontSize', 20);

    aice = load_BSf_daily(exp, 'aice', timenum);
    salt = load_BSf_daily(exp, 'salt', timenum);

    vari = salt(:,:,g.N);

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(end)) = climit(end);

    T = pcolorm(g.lat_rho,g.lon_rho,vari);
    caxis(climit)
    colormap(color)
    uistack(T,'bottom')

%     [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], 'LineWidth', 2, 'LineStyle', '--', 'Color', 'k');
%     set(h.Children(2), 'FaceColor', 'none')
%     % set(h.Children(2), 'FaceAlpha', 0.4)
%     set(h.Children(3), 'FaceColor', 'none')
    plot_map(map, 'eqaconic', 'l')
    plabel('FontSize', 12)
    mlabel('FontSize', 12)

    icf = aice;
    icf(size(g.lat_rho,1),1)=0.5;
    ind = find(isnan(icf)==1);
    icf(ind)=0.0;
    icf = icf*1.0;

    set(T,'alphadata',1-icf,'AlphaDataMapping','none','facealpha','flat','edgecolor','none');

    if isfirst == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = climit(1):1:climit(end);
        c.FontSize = 12;
    end

    % Make gif
    gifname = [savename, '_', map, '_', ystr, '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if isfirst == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
    delete(T)

    isfirst = 0;
end % ti