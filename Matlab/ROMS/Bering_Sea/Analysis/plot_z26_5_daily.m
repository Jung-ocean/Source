%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS z26.5
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'NW_Bering';

exp = 'Dsm4_mk2';
yyyy = 2023;
ystr = num2str(yyyy);
mm_all = 1:6;

timenum_all = datenum(yyyy,mm_all(1),1):datenum(yyyy,mm_all(end),eomday(yyyy,mm_all(end)));

% Load grid information
g = grd('BSf');

% Figure properties
colormap = 'jet';
% climit = [29 34];
climit = [-700 0];
interval = 50;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'm';

savename = 'z26_5';

f1 = figure; hold on
set(gcf, 'Position', [1 200 800 500])
plot_map(map, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');

for ti = 1:length(timenum_all)
    
    timenum = timenum_all(ti);
    filenum = timenum - datenum(2018,7,1) + 1;

    file = get_ncfilename(exp, 'avg', filenum);
    zeta = ncread(file, 'zeta');
    temp = ncread(file, 'temp');
    salt = ncread(file, 'salt');
    salt(salt < 0) = 0;
    
    z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    
    SA = salt;
    pt = temp;
    CT = gsw_CT_from_pt(SA,pt);
    pden = gsw_rho(SA,CT,0);

    mask = g.mask_rho;
    z26_5 = NaN(size(zeta));
    for i = 1:size(pden,1)
        for j = 1:size(pden,2)
            if mask(i,j) == 1
                pden_tmp = squeeze(pden(i,j,:));
                z_tmp = squeeze(z(i,j,:));
                try
                    z26_5(i,j) = interp1(pden_tmp, z_tmp, 1026.5);
                catch
                end
            end
        end
    end

    vari = z26_5;

    p = plot_contourf([], g.lat_rho, g.lon_rho, vari, color, climit, contour_interval);
%     plotm([62.1252 60.5932], [-185.1117 -182.7350], '--k', 'LineWidth', 2);

    if ti == 1
        c = colorbar;
        c.Title.String = unit;
    end

    title(['z26.5 (', datestr(timenum, 'mmm dd, yyyy'), ')'], 'FontSize', 15);

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