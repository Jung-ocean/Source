%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS aice to Satellite (ASI) data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2020:2020;
mm_all = 2:2;
% dd_all = 1:28;
depth_shelf = 200; % m

switch vari_str
    case 'aice'
        climit_model = [0 1];
        climit_sat = climit_model;
        unit = '';
end

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm4';
filepath_control = [filepath_all, case_control, '/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

% Satellite SSH
% ASI
filepath_ASI = ['/data/jungjih/Observations/Sea_ice/ASI/daily_ROMSgrid/'];

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
            file = [filepath_control, filename];
            vari_control = ncread(file, 'aice')';
            ot = ncread(file, 'ocean_time');

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            title(t, time_title, 'FontSize', 25);

            nexttile(1)
            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(1));
            end

            T(1) = pcolorm(lat,lon,vari_control.*mask);
            uistack(T(1),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
                c = colorbar;
                %             c.Title.String = unit;
                c.Ticks = [climit_model(1):.5:climit_model(end)];
            end
            title(['ROMS'], 'Interpreter', 'None')

            % Satellite
            filepath_sat = filepath_ASI;
            filepattern_sat = fullfile(filepath_sat, (['*', ystr, mstr, dstr, '*.nc']));
            filename_sat = dir(filepattern_sat);

            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,'longitude'))';
            lat_sat = double(ncread(file_sat,'latitude'))';
            vari_sat = double(squeeze(ncread(file_sat,'z'))')/100;

            % Tile
            nexttile(2);

            if mi == 1 && di == 1
                plot_map('Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'k');
            else
                delete(T(2));
            end
            T(2) = pcolorm(lat,lon,vari_sat.*mask);
            uistack(T(2),'bottom')
            caxis(climit_sat)
            if mi == 1 && di == 1
                c = colorbar;
                %             c.Title.String = unit;
                c.Ticks = [climit_sat(1):.5:climit_sat(end)];
            end

            title('Satellite (ASI)', 'Interpreter', 'None')

            t.TileSpacing = 'compact';
            t.Padding = 'compact';

            pause(1)
            print(['cmp_', vari_str, '_satellite_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');

            % Make gif
            gifname = ['cmp_', vari_str, '_satellite_daily_', ystr, mstr, '.gif'];

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