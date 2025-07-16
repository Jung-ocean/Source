%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS variable to ROMS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'temp';
yyyy_all = 2022:2022;
mm_all = 1:6;
layer = 1;
lstr = num2str(layer);
% dd_all = 1:28;
% depth_shelf = 200; % m

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

switch vari_str
    case 'aice'
        color = 'parula';
        climit = [0 1];
        interval = 0.5;
        unit = '';

        lat_plot = lat;
        lon_plot = lon;
    case 'zeta'
        color = 'redblue';
        climit = [-1 1];
        interval = 0.5;
        unit = 'm';

        lat_plot = lat;
        lon_plot = lon;
    case 'svstr'
        color = 'redblue';
        climit = [-1 1];
        interval = 0.5;
        unit = 'N/m^2';

        lat_plot = g.lat_v;
        lon_plot = g.lon_v;
        mask = g.mask_v./g.mask_v;

    case 'temp'
        colormap = 'jet';
        climit = [-2 12];
        interval = 1;
        [color, contour_interval] = get_color(colormap, climit, interval);
               
        colormap2 = 'redblue';
        climit2 = [-1 1];
        interval2 = 0.1;
        [color2, contour_interval2] = get_color(colormap2, climit2, interval2);

        unit = '^oC';

        lat_plot = lat;
        lon_plot = lon;

    case 'salt'
        colormap = 'jet';
        climit = [29 34];
        interval = 0.25;
        [color, contour_interval] = get_color(colormap, climit, interval);
               
        colormap2 = 'redblue';
        climit2 = [-.5 .5];
        interval2 = 0.1;
        [color2, contour_interval2] = get_color(colormap2, climit2, interval2);

        unit = 'g/kg';

        lat_plot = lat;
        lon_plot = lon;
end

% Model control
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/'];
case_con = '';
label_con = 'Control';
filepath_con = [filepath_all, case_con, '/ncks/'];

% Model experiment
case_exp = 'Dsm4_s7b3';
label_exp = 's7b3';
filepath_exp = [filepath_all, case_exp, '/ncks/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Figure
    f1 = figure; hold on;
    set(gcf, 'Position', [1 200 1800 500])
    t = tiledlayout(1,3);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [vari_str, '_layer_', lstr, '_', fstr, '.nc'];
            
            % ROMS control
            file = [filepath_con, filename];
            vari_con = ncread(file, vari_str);
            ot = ncread(file, 'ocean_time');

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            title(t, {[vari_str, ' layer ', lstr, ' (', time_title, ')'], ''}, 'FontSize', 20);

            ax1 = nexttile(1);
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200 1000], 'k');
            else
                delete(T(1));
            end

            T(1) = plot_contourf(ax1, lat_plot,lon_plot,vari_con.*mask, color, climit, contour_interval);

            title([label_con], 'Interpreter', 'None', 'FontSize', 15)

            % ROMS experiment
            file = [filepath_exp, filename];
            vari_exp = ncread(file, vari_str);
    
            ax2 = nexttile(2);
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200 1000], 'k');
            else
                delete(T(2));
            end

            T(2) = plot_contourf(ax2, lat_plot,lon_plot,vari_exp.*mask, color, climit, contour_interval);
            if mi == 1 && di == 1
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = [climit(1):interval:climit(end)];

                plabel off
            end
            title([label_exp], 'Interpreter', 'None', 'FontSize', 15)

            % Difference
            vari_diff = vari_exp - vari_con;

            ax3 = nexttile(3);
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200 1000], 'k');

                plabel off
            else
                delete(T(3));
            end

            T(3) = plot_contourf(ax3, lat_plot,lon_plot,vari_diff.*mask, color2, climit2, contour_interval2);
            if mi == 1 && di == 1
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = [climit2(1):interval2:climit2(end)];
            end
            title(['Difference'], 'Interpreter', 'None', 'FontSize', 15)

            t.TileSpacing = 'compact';
            t.Padding = 'compact';

%             pause(1)
%             print(['cmp_', vari_str, '_ROMS_to_ROMS_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');

            % Make gif
            gifname = ['cmp_', vari_str, '_layer_', lstr, '_ROMS_to_ROMS_daily_', ystr, '.gif'];

            frame = getframe(f1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if mi == 1 && di == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end

            disp([ystr, mstr, dstr, '...'])
        end % di
    end % mi
end % yi