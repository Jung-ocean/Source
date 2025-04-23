%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS output SST to LEO daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
vari_str = 'SST';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm,'%02i');

region = 'Gulf_of_Anadyr';

switch vari_str
    case 'SST'
        climit = [-2 12];
        interval = 2;
        contour_interval = climit(1):interval:climit(2);
        num_color = diff(climit)/interval;
        color = jet(num_color);
        unit = '^oC';
end

text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/'];

% LEO
filepath_all_sat = ['/data/jungjih/Observations/Satellite_SST/LEO/daily/'];

% Load grid information
g = grd('BSf');
startdate = datenum(2018,7,1);
mask = g.mask_rho./g.mask_rho;

f1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(2,4);

for fi = 1:eomday(0,mm)
    dd = fi;

    timenum_title = datenum(0,mm,dd);
    % Figure title
    title(t, ['SST (', datestr(timenum_title, 'mmm dd'), ')'], 'FontSize', 25);

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi); ystr = num2str(yyyy);
        timenum = datenum(yyyy,mm,dd);
        filenum = timenum - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = [exp, '_avg_', fstr, '.nc'];
        file = [filepath_control, filename];
        if ~exist(file)
            vari = NaN;
        else
            vari = mask.*ncread(file, 'temp', [1 1 g.N 1], [Inf Inf 1 Inf])';
        end

        % ROMS plot
        nexttile(yi); cla
        plot_map(region, 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

        % Convert lat/lon to figure (axis) coordinates
        [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
        vari(vari < climit(1)) = climit(1);
        vari(vari > climit(2)) = climit(2);
        [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
        caxis(climit)
        colormap(color)
        uistack(T,'bottom')
        %     plot_map(map, 'mercator', 'l')

        if fi == 1 && yi == 1
            c = colorbar;
            c.Layout.Tile = 'east';
            c.Title.String = unit;
            %         c.Ticks = climit_model(1):4:climit_model(end);
            c.FontSize = 15;
        end
        t1 = textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS);
        t2 = textm(text2_lat, text2_lon, ystr, 'FontSize', text_FS);

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
        nexttile(4+yi); cla
        plot_map(region, 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 75 100 200], 'k');

        p = pcolorm(lat_sat, lon_sat, vari_sat);
        colormap(color)
        caxis(climit)
        uistack(p, 'bottom')

        t3 = textm(text1_lat, text1_lon, 'LEO', 'FontSize', text_FS);
        t4 = textm(text2_lat, text2_lon, ystr, 'FontSize', text_FS);
    end % yi

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    % Make gif
    gifname = ['cmp_SST_to_LEO_', mstr, '_daily.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if fi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end
end % fi