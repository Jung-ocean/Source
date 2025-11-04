%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS hice to Satellite (SMOS - SMAP combined) data and CICE daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Bering';

exp = 'Dsm4_LCda';
vari_str = 'hice';
vari_str_CICE = 'hi';
yyyy_all = 2020:2020;
mm_all = 1:6;
% dd_all = 1:28;

isthin = 0;

switch vari_str
    case 'hice'
        if isthin == 1
            climit_model = [0 55];
            num_color = 11;
        else
            climit_model = [0 100];
            num_color = 20;
        end
        climit_sat = climit_model;
        unit = 'cm';
end

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);

% Satellite thin ice thickness
% SMOS-SMAP combined
filepath_sat_all = ['/data/smithj28/Obersvations/Thin_ice/'];

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Figure
    h1 = figure; hold on;
    set(gcf, 'Position', [1 200 1800 500])
    t = tiledlayout(1,3);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [exp, '_avg_', fstr, '.nc'];
            file = [filepath_control, filename];

            if strcmp(exp, 'Dsm4')
            if filenum == 0119
                file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2018/Dsm4_rhZop05/Sum_2018_Dsm4_rhZop05_avg_0119.nc';
            elseif filenum == 1640
                file = '/data/sdurski/ROMS_BSf/Output/NoIce/SumFal_2022/Dsm4_nKC/SumFal_2022_Dsm4_nKC_avg_1640.nc';
            elseif filenum == 1826
                file = '/data/sdurski/ROMS_BSf/Output/Ice/Winter_2022/Dsm4_nKC/Output/Winter_2022_Dsm4_nKC_avg_1826.nc';
            end
            end

            vari_control = 100*ncread(file, vari_str);
            ot = ncread(file, 'ocean_time');

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            if strcmp(region, 'Bering')
                title(t, {time_title, ''}, 'FontSize', 25);
            else
                title(t, time_title, 'FontSize', 25);
            end

            nexttile(2)
            if mi == 1 && di == 1
                plot_map(region, 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200], 'Color', [0.8510 0.3255 0.0980]);
            else
                delete(T(1));
            end

            if isthin == 1
                vari_control(vari_control > 50) = 55;
            end

            T(1) = pcolorm(lat,lon,vari_control.*mask);
            colormap(jet(num_color))
            uistack(T(1),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
%                 c = colorbar;
                %             c.Title.String = unit;
%                 c.Ticks = [climit_model(1):.5:climit_model(end)];
            end
            title(['ROMS'], 'Interpreter', 'None', 'FontSize', 20)

            % Satellite
            filepath_sat = [filepath_sat_all, ystr, '/'];
            filename_sat = [num2str(yyyy-1), '_', ystr, '_combined_thickness.mat'];

            file_sat = [filepath_sat, filename_sat];
            if mi == 1 && di == 1
                data_sat = load(file_sat);
                [gc, tmp] = load_CICE_daily(vari_str_CICE, timenum);
            end

            timenum_sat = datenum(data_sat.thin_ice_data.dates);
            lon_sat = gc.lon_rho;
            lat_sat = gc.lat_rho;
            mask_sat = gc.mask_rho;
            index = find(timenum_sat == timenum);

            if isthin == 1
                vari_sat = data_sat.thin_ice_data.thickness.rect_lon_lat(:,:,index);
            else
                vari_sat = NaN.*mask_sat;
            end

            % Tile
            nexttile(1);

            if mi == 1 && di == 1
                plot_map(region, 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 100 200], 'Color', [0.8510 0.3255 0.0980]);
            else
                delete(T(2));
            end
            T(2) = pcolorm(lat_sat,lon_sat,vari_sat.*mask_sat);
            colormap(jet(num_color))
            uistack(T(2),'bottom')
            caxis(climit_sat)
            if mi == 1 && di == 1
%                 c = colorbar;
                %             c.Title.String = unit;
%                 c.Ticks = [climit_sat(1):.5:climit_sat(end)];
            end

            title('Satellite (SMOS & SMAP)', 'Interpreter', 'None', 'FontSize', 20)

            nexttile(3)
            [gc, vari] = load_CICE_daily(vari_str_CICE, timenum);
            if mi == 1 && di == 1
                plot_map(region, 'mercator', 'l')
                hold on;
                contourm(gc.lat_rho, gc.lon_rho, gc.h, [50 100 200], 'Color', [0.8510 0.3255 0.0980]);
            else
                delete(T(3));
            end
            vari = vari.*100;
            if isthin == 1
                vari(vari > 50) = 55;
            end
            T(3) = pcolorm(gc.lat_rho,gc.lon_rho,vari.*gc.mask_rho);
            colormap(jet(num_color))
            uistack(T(3),'bottom')
            caxis(climit_model)
            if mi == 1 && di == 1
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = [climit_model(1):5:climit_model(end)];
            end
            title(['CICE'], 'Interpreter', 'None', 'FontSize', 20)
            
            t.TileSpacing = 'compact';
            t.Padding = 'compact';

%             pause(1)
%             print(['cmp_', vari_str, '_satellite_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');

            % Make gif
            if isthin == 1
                gifname = ['cmp_', vari_str, '_thin_satellite_CICE_daily_', region, '_', ystr, '.gif'];
            else
                gifname = ['cmp_', vari_str, '_satellite_CICE_daily_', region, '_', ystr, '.gif'];
            end

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