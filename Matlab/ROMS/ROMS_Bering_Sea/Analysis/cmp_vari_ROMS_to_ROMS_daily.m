%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS variable to ROMS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'svstr';
yyyy_all = 2020:2020;
mm_all = 2:2;
% dd_all = 1:28;
depth_shelf = 200; % m

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
        climit_model = [0 1];
        interval = 0.5;
        climit_sat = climit_model;
        unit = '';

        lat_plot = lat;
        lon_plot = lon;
    case 'zeta'
        color = 'redblue';
        climit_model = [-1 1];
        interval = 0.5;
        climit_sat = climit_model;
        unit = 'm';

        lat_plot = lat;
        lon_plot = lon;
    case 'svstr'
        color = 'redblue';
        climit_model = [-1 1];
        interval = 0.5;
        climit_sat = climit_model;
        unit = 'N/m^2';

        lat_plot = g.lat_v;
        lon_plot = g.lon_v;
        mask = g.mask_v./g.mask_v;

    case 'salt'
        color = 'jet';
        climit_model = [31.5 33.5];
        interval = 0.5;
        climit_sat = climit_model;
        unit = 'g/kg';

        lat_plot = lat;
        lon_plot = lon;
end

% Model control
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_con = 'Dsm2_spng';
label_con = 'Control';
filepath_con = [filepath_all, case_con, '/ncks/'];

% Model experiment
case_exp = 'Dsm2_spng_awdrag';
label_exp = 'Wind drag only';
filepath_exp = [filepath_all, case_exp, '/ncks/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Figure
    h1 = figure; hold on;
    set(gcf, 'Position', [1 200 1800 650])
    t = tiledlayout(1,2);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [vari_str, '_', fstr, '.nc'];
            
            % ROMS control
            file = [filepath_con, filename];
            vari_con = ncread(file, vari_str)';
            ot = ncread(file, 'ocean_time');

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            title(t, [vari_str, ' (', time_title, ')'], 'FontSize', 25);

            nexttile(1)
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(1));
            end

            T(1) = pcolorm(lat_plot,lon_plot,vari_con.*mask);
            colormap(color)
            uistack(T(1),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = [climit_model(1):interval:climit_model(end)];
            end
            title([label_con], 'Interpreter', 'None', 'FontSize', 15)

            % ROMS experiment
            file = [filepath_exp, filename];
            vari_exp = ncread(file, vari_str)';
    
            nexttile(2)
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(2));
            end

            T(2) = pcolorm(lat_plot,lon_plot,vari_exp.*mask);
            colormap(color)
            uistack(T(2),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = [climit_model(1):interval:climit_model(end)];
            end
            title([label_exp], 'Interpreter', 'None', 'FontSize', 15)

            t.TileSpacing = 'compact';
            t.Padding = 'compact';

            pause(1)
            print(['cmp_', vari_str, '_ROMS_to_ROMS_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');

            % Make gif
            gifname = ['cmp_', vari_str, '_ROMS_to_ROMS_daily_', ystr, mstr, '.gif'];

            frame = getframe(h1);
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