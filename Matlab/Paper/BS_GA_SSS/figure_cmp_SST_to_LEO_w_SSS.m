clear; clc; close all

exp = 'Dsm4';
vari_str = 'SST';
yyyy_all = 2019:2022;
timenums = [datenum(2019,7,27) datenum(2020,7,21) datenum(2021,7,22) datenum(2022,7,15)];
mm = 7;
mstr = num2str(mm,'%02i');

region = 'Gulf_of_Anadyr';

labels_LEO = {'a', 'b', 'c', 'd'};
labels_ROMS = {'e', 'f', 'g', 'h'};
labels_ROMS_SSS = {'i', 'j', 'k', 'l'};

switch vari_str
    case 'SST'
        climit = [0 13];
        interval = 1;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = '^oC';
end

climit2 = [29 34];
interval2 = 0.25;
contour_interval2 = climit2(1):interval2:climit2(2);
num_color2 = diff(climit2)/interval2;
color2 = jet(num_color2);
unit2 = 'psu';

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 14;

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/'];

% LEO
filepath_all_sat = ['/data/jungjih/Observations/Satellite_SST/LEO/daily/'];

% Load grid information
g = grd('BSf');
startdate = datenum(2018,7,1);
mask = g.mask_rho./g.mask_rho;

figure;
set(gcf, 'Position', [1 200 1800 900])

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    timenum = timenums(yi);
    filenum = timenum - startdate + 1;
    fstr = num2str(filenum, '%04i');
    filename = [exp, '_avg_', fstr, '.nc'];
    file = [filepath_control, filename];
    if ~exist(file)
        vari = NaN;
        vari_SSS = NaN;
    else
        vari = mask.*ncread(file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf]);
        vari_SSS = mask.*ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 Inf]);
    end

    % ROMS plot
    ax1 = subplot('Position', [.02+.16*(yi-1) .38 .15 .25]); hold on;
    plot_map(region, 'mercator', 'l')
    text(-0.16, 1.55, labels_ROMS{yi}, 'FontSize', 20)
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari(vari < climit(1)) = climit(1);
    vari(vari > climit(2)) = climit(2);
    [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
    caxis(ax1, climit)
    colormap(ax1, color)
    uistack(T,'bottom')
    %     plot_map(map, 'mercator', 'l')

    t1 = textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS);
    t2 = textm(text1_lat-.6, text1_lon, 'SST', 'FontSize', text_FS);
%     t3 = textm(text2_lat, text2_lon, datestr(timenum, 'mmm dd, yyyy'), 'FontSize', text_FS);

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off

    % Satellite
    filepath_sat = [filepath_all_sat, ystr, '/'];
    filenum_sat = timenum - datenum(yyyy,1,1) + 1;
    fstr = num2str(filenum_sat, '%03i');
    filename = dir([filepath_sat, fstr, '/', ystr, '*.nc']);
    file = [filename.folder, '/', filename.name];

    lat_sat = double(ncread(file, 'lat'));
    lon_sat = double(ncread(file, 'lon'));
    vari_sat = double(ncread(file, 'sea_surface_temperature')') - 273.15;

    index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
    vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

    lon_sat = lon_sat - 180;

    latind = find(55 < lat_sat & lat_sat < 68);
    lonind = find(-200 < lon_sat & lon_sat < -150);
    lat_sat = lat_sat(latind);
    lon_sat = lon_sat(lonind);
    vari_sat = vari_sat(latind,lonind);
    [lon2, lat2] = meshgrid(lon_sat, lat_sat);

    % Sat plot
    ax2 = subplot('Position', [.02+.16*(yi-1) .66 .15 .25]); hold on;
    plot_map(region, 'mercator', 'l')
    text(-0.16, 1.55, labels_LEO{yi}, 'FontSize', 20)
    hold on;
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    p = pcolorm(lat_sat, lon_sat, vari_sat);
    colormap(ax2, color)
    caxis(ax2, climit)
    uistack(p, 'bottom')

    t4 = textm(text1_lat, text1_lon, 'L3S-LEO', 'FontSize', text_FS);
    t5 = textm(text1_lat-.6, text1_lon, 'SST', 'FontSize', text_FS);
%     t6 = textm(text2_lat, text2_lon, datestr(timenum, 'mmm dd, yyyy'), 'FontSize', text_FS);
    title(datestr(timenum, 'mmm dd, yyyy'), 'FontSize', text_FS)

    textm(62.9, -182.6, 'CN', 'FontSize', 15)

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel off

    % ROMS SSS
    ax3 = subplot('Position', [.02+.16*(yi-1) .1 .15 .25]); hold on;
    plot_map(region, 'mercator', 'l')
    text(-0.16, 1.55, labels_ROMS_SSS{yi}, 'FontSize', 20)
    contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

    % Convert lat/lon to figure (axis) coordinates
    [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
    vari_SSS(vari_SSS < climit2(1)) = climit2(1);
    vari_SSS(vari_SSS > climit2(2)) = climit2(2);
    [cs, T] = contourf(x, y, vari_SSS, contour_interval2, 'LineColor', 'none');
    caxis(ax3,climit2)
    colormap(ax3,color2)
    uistack(T,'bottom')
    %     plot_map(map, 'mercator', 'l')

    t7 = textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS);
    t8 = textm(text1_lat-.6, text1_lon, 'SSS', 'FontSize', text_FS);
%     t9 = textm(text2_lat, text2_lon, datestr(timenum, 'mmm dd, yyyy'), 'FontSize', text_FS);

    if yi ~= 1
        plabel off
    else
        plabel('FontSize', 10);
    end
    mlabel('FontSize', 10);
end % yi

c = colorbar(ax1, 'Position', [.66 .38 .01 .53]);
c.Title.String = unit;
c.FontSize = 12;

c = colorbar(ax3, 'Position', [.66 .1 .01 .25]);
c.Title.String = unit2;
c.FontSize = 12;

dfdf
exportgraphics(gcf,'figure_cmp_SST_to_LEO_w_SSS.png','Resolution',150) 