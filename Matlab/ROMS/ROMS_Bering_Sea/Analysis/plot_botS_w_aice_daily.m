%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS botS with sea ice concentration daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
yyyy_all = 2019:2022;
mm = 6;
mstr = num2str(mm, '%02i');
startdate = datenum(2018,7,1);

filepath = ['/data/sdurski/ROMS_BSf/Output/Multi_year/', exp, '/'];

% Load grid information
g = grd('BSf');

% Figure properties
% Salinity
interval = 0.25;
climit = [29 34];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);
unit = 'psu';
savename = 'botS_w_aice';

% Sea ice concentration
interval_aice = 0.1;
climit_aice = [0 1];
contour_interval_aice = climit_aice(1):interval_aice:climit_aice(2);
num_color = diff(climit)/interval;
color_aice = gray(num_color);

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

h1 = figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);
% Figure title
for di = 1:eomday(9999,mm)
    
    if di > 1
        delete(h)
        delete(haice)
    end
    
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'yyyy');

    timenum = datenum(yyyy,mm,di);
    title(t, ['Bottom S with aice 30 % line (', datestr(timenum, 'mmm dd'), ')'], 'FontSize', 20);

    filenum = timenum - startdate + 1;
    fstr = num2str(filenum, '%04i');

    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath, filename];
    vari = squeeze(ncread(file, 'salt', [1 1 1 1], [Inf Inf 1 Inf]))';
    aice = ncread(file, 'aice')';
    
    nexttile(yi); hold on;
    if  di == 1 & yi == 1
        plot_map(map, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

        % Convert lat/lon to figure (axis) coordinates
        [x, y] = mfwdtran(g.lat_rho, g.lon_rho);
    end
       
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(2)) = climit(2);
    [cs, h(yi)] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(climit)
    colormap(color)
    uistack(h(yi), 'bottom')
    plot_map(map, 'mercator', 'l')    

    if di == 1 & yi == 4
        c = colorbar;
        c.Title.String = unit;
    end
    
    [cs, haice(yi)] = contour(x, y, aice, [0.30 0.30], 'w', 'LineWidth', 4);
    
    if di == 1
        if strcmp(map, 'Gulf_of_Anadyr')
            textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
            textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
        else
            title(['ROMS (', title_str, ')'])
        end
    end
end % yi

if di == 1
    t.Padding = 'compact';
    t.TileSpacing = 'compact';
end

% Make gif
gifname = ['botS_w_aice_', mstr, '.gif'];

frame = getframe(h1);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
if di == 1
    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
else
    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
end

end