%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot angle of wind, ice, and current
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

yyyy = 2022;
mm_all = 5:5;

lon_target = -176;
lat_target = 63.5;
% lon_target = -176.9945; 
% lat_target = 63.3551;

startdate = datenum(2018,7,1);

g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
area=dx.*dy;
area_target = interp2(g.lon_rho, g.lat_rho, area, lon_target, lat_target);

ERA5_filepath = '/data/sdurski/ROMS_Setups/Forcing/Atm/Bering_Sea/';

switch map
    case 'Gulf_of_Anadyr'
        text_ice_lat = 66.1;
        text_ice_lon = -184.8;

        text_wind_lat = 63.7;
        text_wind_lon = -184.8;

        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;

        color_ice = 'r';
        interval_ice = 30;
        scale_ice = 6;
        scale_ice_value = 0.2;
        scale_ice_lat = text_ice_lat-0.5;
        scale_ice_lon = text_ice_lon;
        scale_ice_text = '20 cm/s';
        scale_ice_text_lat = scale_ice_lat-0.4;
        scale_ice_text_lon = text_ice_lon;

        color_wind = 'k';
        interval_wind = 6;
        scale_wind = 0.5;
        scale_wind_value = 3;
        scale_wind_lat = text_wind_lat-0.5;
        scale_wind_lon = text_wind_lon;
        scale_wind_text = '3 m/s';
        scale_wind_text_lat = scale_wind_lat-0.4;
        scale_wind_text_lon = text_wind_lon;
end

% Figure properties
interval = .4;
climit = [0 2];
contour_interval = climit(1):interval:climit(2);
num_color = diff(climit)/interval;
color = jet(num_color);

cutoff_hice = 0.1;
fac = 1e6;
unit = ['x10^', num2str(log10(fac)), ' m^3'];
savename = 'vice_w_angle';

if yyyy < 2021
    exp = 'Dsm4_phiZo';
else
    exp = 'Dsm4_nKC';
end

h1 = figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);

ystr_qck = num2str(yyyy-1);
ystr = num2str(yyyy);
dataind = 0;
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        for Hi = [0 6 12 18]
            dataind = dataind+1;

            filepath = ['/data/sdurski/ROMS_BSf/Output/Ice/Winter_', ystr_qck, '/', exp, '/'];
            filenum = 4*(datenum(yyyy,mm,di,Hi,0,0) - startdate - 0.25);
            fstr = num2str(filenum, '%04i');
            filename = ['Winter_', ystr_qck, '_', exp, '_qck_', fstr, '.nc'];
            file = [filepath, filename];
            ot = ncread(file, 'ocean_time');
            timenum(dataind) = ot/60/60/24 + datenum(1968,5,23);
            timevec = datevec(timenum(dataind));

            % Current
            u_tmp = ncread(file, 'u_sur_eastward')';
            u(dataind) = interp2(g.lon_rho, g.lat_rho, u_tmp, lon_target, lat_target);
            v_tmp = ncread(file, 'v_sur_northward')';
            v(dataind) = interp2(g.lon_rho, g.lat_rho, v_tmp, lon_target, lat_target);

            % Ice
            hi_tmp = ncread(file, 'hice')';
            hi(dataind) = interp2(g.lon_rho, g.lat_rho, hi_tmp, lon_target, lat_target);
            ui_tmp = ncread(file, 'uice')';
            ui(dataind) = interp2(g.lon_u, g.lat_u, ui_tmp, lon_target, lat_target);
            vi_tmp = ncread(file, 'vice')';
            vi(dataind) = interp2(g.lon_v, g.lat_v, vi_tmp, lon_target, lat_target);
            
            skip = 1;
            npts = [0 0 0 0];

            [uice_rho,vice_rho,lonred,latred,maskred] = uv_vec2rho(ui_tmp,vi_tmp,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
            uice_rho = uice_rho.*maskred;
            vice_rho = vice_rho.*maskred;

            ERA5_filename = ['BSf_ERA5_', num2str(timevec(:,1)), '_', num2str(timevec(:,2), '%02i'), '_ni2_a_frc.nc'];
            ERA5_file = [ERA5_filepath, '/', ERA5_filename];

            ERA5_lon = double(ncread(ERA5_file, 'lon'))';
            ERA5_lat = double(ncread(ERA5_file, 'lat'))';
            ERA5_time = double(ncread(ERA5_file, 'sfrc_time'));
            ERA5_timevec = datevec(ERA5_time + datenum(1968,5,23));
            ERA5_timenum = datenum(ERA5_timevec);
            windex = find(ERA5_timenum == timenum(dataind));
            uwind_tmp = double(ncread(ERA5_file, 'Uwind', [1 1 windex], [Inf Inf 1]))';
            uwind(dataind) = interp2(ERA5_lon, ERA5_lat, uwind_tmp, lon_target, lat_target);
            vwind_tmp = double(ncread(ERA5_file, 'Vwind', [1 1 windex], [Inf Inf 1]))';
            vwind(dataind) = interp2(ERA5_lon, ERA5_lat, vwind_tmp, lon_target, lat_target);

            % Map plot
            ax1 = nexttile(1); cla; hold on
            plot_map(map, 'mercator', 'l')
            contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

            vari = area.*hi_tmp/fac;
            % Convert lat/lon to figure (axis) coordinates
            [x, y] = mfwdtran(g.lat_rho, g.lon_rho);  % Convert lat/lon to projected x, y coordinates
            vari(vari < climit(1)) = climit(1);
            vari(vari > climit(end)) = climit(end);
            [cs, T] = contourf(x, y, vari, contour_interval, 'LineColor', 'none');
            caxis(climit)
            colormap(ax1, color)
            uistack(T,'bottom')
            plot_map(map, 'mercator', 'l')
            title('Sea ice volume')

            if mi == 1 & di == 1 & Hi == 0
                c = colorbar;
                c.Title.String = unit;
                c.Ticks = contour_interval;
            end

            % Sea ice velocity plot
            uice_rho(hi_tmp < cutoff_hice) = NaN;
            vice_rho(hi_tmp < cutoff_hice) = NaN;

            qice = quiverm(g.lat_rho(1:interval_ice:end, 1:interval_ice:end), ...
                g.lon_rho(1:interval_ice:end, 1:interval_ice:end), ...
                vice_rho(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
                uice_rho(1:interval_ice:end, 1:interval_ice:end).*scale_ice, ...
                0);

            qice(1).Color = color_ice;
            qice(2).Color = color_ice;
            qice(1).LineWidth = 2;
            qice(2).LineWidth = 2;

            qscale = quiverm(scale_ice_lat, scale_ice_lon, 0.*scale_ice, scale_ice_value.*scale_ice, 0);
            qscale(1).Color = color_ice;
            qscale(2).Color = color_ice;
            qscale(1).LineWidth = 2;
            qscale(2).LineWidth = 2;
            tscale = textm(scale_ice_text_lat, scale_ice_text_lon, scale_ice_text, 'Color', color_ice, 'FontSize', 10);

            % Wind plot
            latind = find(ERA5_lat(:,1) < max(max(g.lat_rho)) & ERA5_lat(:,1) > min(min(g.lat_rho)));
            lonind = find(ERA5_lon(1,:) < max(max(g.lon_rho)) & ERA5_lon(1,:) > min(min(g.lon_rho)));
            ERA5_uwind_tmp = uwind_tmp(latind, lonind);
            ERA5_vwind_tmp = vwind_tmp(latind, lonind);

            ERA5_lat2 = ERA5_lat(latind,lonind);
            ERA5_lon2 = ERA5_lon(latind,lonind);
            
            qwind = quiverm(ERA5_lat2(1:interval_wind:end, 1:interval_wind:end), ...
                ERA5_lon2(1:interval_wind:end, 1:interval_wind:end), ...
                ERA5_vwind_tmp(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
                ERA5_uwind_tmp(1:interval_wind:end, 1:interval_wind:end).*scale_wind, ...
                0);
            qwind(1).Color = color_wind;
            qwind(2).Color = color_wind;
            qwind(1).LineWidth = 2;
            qwind(2).LineWidth = 2;

            qscale = quiverm(scale_wind_lat, scale_wind_lon, 0.*scale_wind, scale_wind_value.*scale_wind, 0);
            qscale(1).Color = color_wind;
            qscale(2).Color = color_wind;
            qscale(1).LineWidth = 2;
            qscale(2).LineWidth = 2;
            tscale = textm(scale_wind_text_lat, scale_wind_text_lon, scale_wind_text, 'Color', color_wind, 'FontSize', 10);

            uistack(qwind, 'bottom')
            uistack(qice, 'bottom')
            uistack(T,'bottom')

            if strcmp(map, 'Gulf_of_Anadyr')
                t1 = textm(text_ice_lat, text_ice_lon, 'Sea ice', 'Color', color_ice, 'FontSize', text_FS);
                t2 = textm(text_wind_lat, text_wind_lon, 'Wind', 'Color', color_wind, 'FontSize', text_FS);
            end
            
            plotm(lat_target, lon_target, 'xg', 'MarkerSize', 10, 'LineWidth', 3)
            pos1 = get(gca, 'Position');

            % Angle of wind
            ax2 = nexttile(2); cla; hold on; grid on
            axis equal
            quiver(0,0,uwind(dataind),vwind(dataind), 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.5)
            
            xlim([-10 10])
            xticks(-10:5:10)
            ylim([-10 10])
            yticks(-10:5:10)
            xlabel('m/s')
            ylabel('m/s')
            set(gca, 'FontSize', 12)
            title('10 m wind')

            % Angle of ice
            ax3 = nexttile(3); cla; hold on; grid on
            axis equal
            if hi(dataind) < cutoff_hice
                quiver(0,0,0,0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5)
            else
                quiver(0,0,ui(dataind),vi(dataind), 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5)
            end
            
            xlim([-0.5 0.5])
            xticks(-0.5:0.25:0.5)
            ylim([-0.5 0.5])
            yticks(-0.5:0.25:0.5)
            xlabel('m/s')
            ylabel('m/s')
            set(gca, 'FontSize', 12)
            title('Sea ice')

            % Angle of current
            ax4 = nexttile(4); cla; hold on; grid on
            axis equal
            quiver(0,0,u(dataind),v(dataind), 0, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.5)
            title('Surface current')
            
            xlim([-0.5 0.5])
            xticks(-0.5:0.25:0.5)
            ylim([-0.5 0.5])
            yticks(-0.5:0.25:0.5)
            xlabel('m/s')
            ylabel('m/s')
            set(gca, 'FontSize', 12)
            title('Surface current')

            t.Padding = 'compact';
            t.TileSpacing = 'compact';
            
            title(t, {datestr(timenum(dataind), 'mmm dd, yyyy HH:MM'),''}, 'FontSize', 20);

            % Make gif
            gifname = ['vice_w_angle_', ystr, mstr, '_daily.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if dataind == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end

            disp(datestr(timenum(dataind), 'yyyymmdd HH:MM ...'))
        end % Hi
    end % di
end % mi

ui(hi < cutoff_hice) = NaN;
vi(hi < cutoff_hice) = NaN;

speed_wind = sqrt(uwind.*uwind + vwind.*vwind);
speed_ice = sqrt(ui.*ui + vi.*vi);
speed_current = sqrt(u.*u + v.*v);

for di = 1:dataind
    angle_wind_ice(di) = acosd( (uwind(di)*ui(di) + vwind(di)*vi(di)) / (speed_wind(di)*speed_ice(di)) );
    angle_ice_current(di) = acosd( (ui(di)*u(di) + vi(di)*v(di)) / (speed_ice(di)*speed_current(di)) );
end

volume = hi*area_target;

figure; hold on; grid on;
set(gcf, 'Position', [1 200 1800 500])
p = pcolor(timenum, 0:180, repmat(volume/fac,[length(0:180),1])); shading flat
colormap(color);
caxis(climit);
c = colorbar;
c.Title.String = unit;
c.Ticks = contour_interval;
p.FaceAlpha = 0.5;

p1 = plot(timenum, angle_wind_ice, '-ok', 'LineWidth', 2);
p2 = plot(timenum, angle_ice_current, '-or', 'LineWidth', 2);

xticks(timenum(1):1:timenum(end))
datetick('x', 'mmm dd', 'keepticks', 'keeplimits')
ylabel('Angle (\theta)')

set(gca, 'FontSize', 15)

l = legend([p1, p2], 'Angle (wind-ice)', 'Angle (ice-current)');
l.FontSize = 25;

print(['angle_', ystr, mstr], '-dpng')