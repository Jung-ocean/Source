%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS aice to Satellite (ASI) data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'NW_Bering';

exp = 'Dsm4';
vari_str = 'aice';
yyyy_all = 2023:2023;
mm_all = 1:6;
% dd_all = 1:28;

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

% Satellite SSH
% ASI
filepath_ASI = ['/data/jungjih/Observations/Sea_ice/ASI/daily_ROMSgrid/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Figure
    h1 = figure; hold on;
    set(gcf, 'Position', [1 200 1300 500])
    t = tiledlayout(1,2);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [exp, '_avg_', fstr, '.nc'];
            file = [filepath_control, filename];

            if filenum == 0119
                file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
            elseif filenum == 1640
                file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
            elseif filenum == 1826
                file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
            end

            vari_control = ncread(file, 'aice');
            ot = ncread(file, 'ocean_time');

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            title(t, time_title, 'FontSize', 25);

            nexttile(2)
            if mi == 1 && di == 1
                plot_map(region, 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200], 'Color', [0.8510 0.3255 0.0980]);
            else
                delete(T(1));
            end

            T(1) = pcolorm(lat,lon,vari_control.*mask);
            colormap(gray(10))
            uistack(T(1),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
                c = colorbar;
                %             c.Title.String = unit;
                c.Ticks = [climit_model(1):.5:climit_model(end)];
            end
            title(['ROMS'], 'Interpreter', 'None', 'FontSize', 20)

            % Satellite
            filepath_sat = filepath_ASI;
            filepattern_sat = fullfile(filepath_sat, (['*', ystr, mstr, dstr, '*.nc']));
            filename_sat = dir(filepattern_sat);

            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,'longitude'));
            lat_sat = double(ncread(file_sat,'latitude'));
            vari_sat = double(squeeze(ncread(file_sat,'z')))/100;

            % Tile
            nexttile(1);

            if mi == 1 && di == 1
                plot_map(region, 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200], 'Color', [0.8510 0.3255 0.0980]);
            else
                delete(T(2));
            end
            T(2) = pcolorm(lat,lon,vari_sat.*mask);
            colormap(gray(10))
            uistack(T(2),'bottom')
            caxis(climit_sat)
            if mi == 1 && di == 1
%                 c = colorbar;
                %             c.Title.String = unit;
%                 c.Ticks = [climit_sat(1):.5:climit_sat(end)];
            end

            title('Satellite (ASI)', 'Interpreter', 'None', 'FontSize', 20)

            t.TileSpacing = 'compact';
            t.Padding = 'compact';

%             pause(1)
%             print(['cmp_', vari_str, '_satellite_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');

            % Make gif
            gifname = ['cmp_', vari_str, '_satellite_daily_', region, '_', ystr, '.gif'];

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