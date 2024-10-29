%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS uv to Satellite L4 climate
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'uv';
mm_all = 1:12;
depth_shelf = 200; % m
layer = 45;

interval_model = 20;
scale_model = 5;
% interval_sat = 1;
% scale_sat = 1;
climit = [0 0.5];

isice = 0;
aice_value = 0.4;

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/climate/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;

% Satellite SSH
% CMEMS
filepath_CMEMS = ['/data/jungjih/Observations/Satellite_SSH/CMEMS/climate/'];

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    % Figure
    if mi == 1
        h1 = figure; hold on;
        set(gcf, 'Position', [1 200 1800 650])
        t = tiledlayout(1,2);
    end

    filepattern_control = fullfile(filepath_control,(['*climate_', mstr, '*.nc']));
    filename_control = dir(filepattern_control);
    if ~isempty(filename_control)
        file_control = [filepath_control, filename_control.name];
        u_control = ncread(file_control,'u',[1 1 layer 1],[Inf Inf 1 1])';
        v_control = ncread(file_control,'v',[1 1 layer 1],[Inf Inf 1 1])';
        if isice == 1
            try
                aice_mask = ncread(file_control,'aice')';
                aice_mask(aice_mask >= aice_value) = NaN;
                aice_mask(aice_mask < aice_value) = 1;
                mask_with_ice = mask.*aice_mask;
                area_with_ice = area.*aice_mask;
            catch
            end
        else
        end % isice
    else
        u_control = NaN(size(g.lon_u));
        v_control = NaN(size(g.lon_v));
    end

    skip = 1;
    npts = [0 0 0 0];

    [ured,vred,lonred,latred,maskred] = uv_vec2rho(u_control,v_control,lon,lat,g.angle,g.mask_rho,skip,npts);
    ured = ured.*maskred;
    vred = vred.*maskred;
    speed_model = sqrt(ured.*ured + vred.*vred);

    timenum = datenum(9999,mm,15);
    time_title = datestr(timenum, 'mmm');

    % Figure title
    title(t, [time_title, ', Climate'], 'FontSize', 25);

    nexttile(1)
    if mi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
        contourm(lat, lon, h, [50 200], 'k');
    else
        delete(p);
        delete(q);
    end

    if isice == 1
        try
            T(1) = pcolorm(lat,lon,vari_control.*mask_with_ice);
        catch
            T(1) = pcolorm(lat,lon,vari_control.*mask);
        end
    else
        p = pcolorm(lat, lon, speed_model);
        colormap(flipud(pink))
        caxis(climit)

        q = quiverm(latred(1:interval_model:end, 1:interval_model:end), ...
            lonred(1:interval_model:end, 1:interval_model:end), ...
            vred(1:interval_model:end, 1:interval_model:end).*scale_model, ...
            ured(1:interval_model:end, 1:interval_model:end).*scale_model, ...
            0);
    end % isice
    uistack(q,'bottom')
    uistack(p,'bottom')
    %         q(1).Color = [.3 .3 .3];
    %         q(2).Color = [.3 .3 .3];
    q(1).Color = 'k';
    q(2).Color = 'k';

    if mi == 1
        c = colorbar;
        c.Title.String = 'm/s';
        c.Ticks = climit(1):0.1:climit(end);
    end
    title(['ROMS'], 'Interpreter', 'None')

    % Satellite
    filepath_sat = filepath_CMEMS;
    filepattern_sat = fullfile(filepath_sat, (['*climate_', mstr, '*.nc']));

    filename_sat = dir(filepattern_sat);

    if isempty(filename_sat)
        vari_sat_interp = NaN;
    else
        file_sat = [filepath_sat, filename_sat.name];
        lon_sat = double(ncread(file_sat,'longitude'));
        lat_sat = double(ncread(file_sat,'latitude'));
        u_sat = double(squeeze(ncread(file_sat,'ugos'))');
        v_sat = double(squeeze(ncread(file_sat,'vgos'))');

        index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
        u_sat = [u_sat(:,index1) u_sat(:,index2)];
        v_sat = [v_sat(:,index1) v_sat(:,index2)];

        lon_sat = lon_sat - 180;

        if isice == 1
            aice_mask_sat = ncread(file_sat, 'sea_ice_fraction')';

            aice_mask_sat(aice_mask_sat >= aice_value) = NaN;
            aice_mask_sat(aice_mask_sat < aice_value) = 1;

            vari_sat = vari_sat.*aice_mask_sat;
        end

        index_lon = find(lon_sat < max(max(lon))+1 & lon_sat > min(min(lon))-1);
        index_lat = find(lat_sat < max(max(lat))+1 & lat_sat > min(min(lat))-1);

        u_sat_part = u_sat(index_lat,index_lon);
        v_sat_part = v_sat(index_lat,index_lon);

        [lon_sat2, lat_sat2] = meshgrid(lon_sat(index_lon), lat_sat(index_lat));

        u_sat_interp = griddata(lon_sat2, lat_sat2, u_sat_part, lon,lat);
        v_sat_interp = griddata(lon_sat2, lat_sat2, v_sat_part, lon,lat);
        mask_sat = ~isnan(u_sat_interp);
        mask_sat_model = (mask_sat./mask_sat).*mask;
    end

    u_sat_interp = u_sat_interp.*mask_sat_model;
    v_sat_interp = v_sat_interp.*mask_sat_model;
    speed_sat = sqrt(u_sat_interp.*u_sat_interp + v_sat_interp.*v_sat_interp);

    % Tile
    nexttile(2);

    if mi == 1
        plot_map('Bering', 'mercator', 'l')
        hold on;
        contourm(lat, lon, h, [50 200], 'k');
    else
        delete(p2);
        delete(q2);
    end
    p2 = pcolorm(lat, lon, speed_sat);
    colormap(flipud(pink))
    caxis(climit)

    q2 = quiverm(latred(1:interval_model:end, 1:interval_model:end), ...
        lonred(1:interval_model:end, 1:interval_model:end), ...
        v_sat_interp(1:interval_model:end, 1:interval_model:end).*scale_model, ...
        u_sat_interp(1:interval_model:end, 1:interval_model:end).*scale_model, ...
        0);

    uistack(q2,'bottom')
    uistack(p2,'bottom')
    %         q2(1).Color = [.3 .3 .3];
    %         q2(2).Color = [.3 .3 .3];
    q2(1).Color = 'k';
    q2(2).Color = 'k';

    if mi == 1
        c = colorbar;
        c.Title.String = 'm/s';
        c.Ticks = climit(1):0.1:climit(end);
    end

    title('Satellite L4 (CMEMS)', 'Interpreter', 'None')

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    pause(1)
    print(strcat('compare_surface_', vari_str, '_satellite_climate_', datestr(timenum, 'mm')),'-dpng');

    % Make gif
    gifname = ['compare_surface_', vari_str, '_satellite_climate.gif'];

    frame = getframe(h1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if mi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    disp([mstr, '...'])
end % mi