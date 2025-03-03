%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS zeta to Satellite L4 (CMEMS) data
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2018:2022;
mm_all = 1:12;
depth_shelf = 200; % m

switch vari_str
    case 'zeta'
        climit_model = [-30 10];
        climit_sat = [20 60];
        unit = 'm';
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSH
    % CMEMS
    filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/monthly/'];

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        % Figure
        if yi == 1 && mi == 1
            h1 = figure; hold on;
            set(gcf, 'Position', [1 200 1800 650])
            t = tiledlayout(1,2);
        end

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari_control = ncread(file_control,vari_str,[1 1 1],[Inf Inf 1])';
        else
            vari_control = NaN;
        end

        timenum = datenum(yyyy,mm,15);
        time_title = datestr(timenum, 'mmm, yyyy');

        % Figure title
        title(t, time_title, 'FontSize', 25);

        nexttile(1)
        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(lat, lon, h, [50 200], 'k');
        else
            delete(T(1));
        end

        T(1) = pcolorm(lat,lon,100*vari_control.*mask);
        uistack(T(1),'bottom')
        caxis(climit_model)
        if yi == 1 && mi == 1
            c = colorbar;
            c.Title.String = unit;
            c.Ticks = [climit_model(1):10:climit_model(end)];
        end
        title(['ROMS'], 'Interpreter', 'None')

        % Satellite
        filepath_sat = filepath_CMEMS;
        filepattern_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));

        filename_sat = dir(filepattern_sat);

        if isempty(filename_sat)
            vari_sat_interp = NaN;
        else
            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,'longitude'));
            lat_sat = double(ncread(file_sat,'latitude'));
            vari_sat = double(squeeze(ncread(file_sat,'adt'))');

            index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
            vari_sat = [vari_sat(:,index1) vari_sat(:,index2)];

            lon_sat = lon_sat - 180;

            index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
            index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

            vari_sat_part = vari_sat(index_lat,index_lon);

            [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

            vari_sat_interp = griddata(lon_sat2, lat_sat2, vari_sat_part, lon,lat);
            mask_sat = ~isnan(vari_sat_interp);
            mask_sat_model = (mask_sat./mask_sat).*mask;
        end

        % Tile
        nexttile(2);

        if yi == 1 && mi == 1
            plot_map('Bering', 'mercator', 'l')
            hold on;
            contourm(lat, lon, h, [50 200], 'k');
        else
            delete(T(2));
        end
        T(2) = pcolorm(lat,lon,100*vari_sat_interp.*mask_sat_model);
        uistack(T(2),'bottom')
        caxis(climit_sat)
        if yi == 1 && mi == 1
            c = colorbar;
            c.Title.String = unit;
            c.Ticks = [climit_sat(1):10:climit_sat(end)];
        end

        title('Satellite L4 (CMEMS)', 'Interpreter', 'None')

        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        pause(1)
        %     print(strcat('compare_surface_', vari_str, '_satellite_monthly_', datestr(timenum, 'yyyymm')),'-dpng');

        % Make gif
        gifname = ['compare_surface_', vari_str, '_satellite_monthly.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if yi == 1 && mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

        disp([ystr, mstr, '...'])
    end % mi
end % yi