clear; clc; close all

% labels = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'};
li = 0;

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'stream';
yyyy_all = 2019:2022;
mm_all = 1:7;

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
filepath_streamfunction = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/transport/streamfunction/'];

% Load grid information
g = grd('BSf');

% Figure properties
contour_interval = -20:.2:20;

climit = [29 34];
interval = 0.25;
contourf_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.6;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 12;
end

figure;
set(gcf, 'Position', [1 200 1200 900])
% Figure title

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

for yi = 1:length(yyyy_all)
    li = li+1;
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');
    title_mmm = datestr(datenum(yyyy,mm,1), 'mmm');
    title_yyyy = datestr(datenum(yyyy,mm,1), 'yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    vari = squeeze(ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]))';

    subplot('Position', [.04+.12*(yi-1) .85-.13*(mi-1) .12 .12]); hold on;
    plot_map(map, 'mercator', 'l')
%     text(-0.16, 1.55, labels{li}, 'FontSize', 20)
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200 1000], 'w', 'Linewidth', 1.5);

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    [cs, h] = contourf(x, y, vari, contourf_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(h, 'bottom')
    plot_map(map, 'mercator', 'l')
    
    filename = ['psi_', ystr, mstr, '.mat'];
    load([filepath_streamfunction, filename])
    psi_rho = psi_rho/1e6;
    [cpsi, hpsi] = contour(x,y,psi_rho, contour_interval, 'k', 'LineWidth', 1);

    textm(text1_lat, text1_lon, [title_mmm], 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_yyyy], 'FontSize', text_FS)

    if mi ~= 7
        mlabel off
    end
    if yi ~= 1
        plabel off
    end

end % yi

end % mi

c = colorbar('Position', [.52 .07 .01 .90]);
c.Title.String = unit;
c.FontSize = 12;
ddd
exportgraphics(gcf,'figure_SSS_w_streamfunction_all.png','Resolution',150)