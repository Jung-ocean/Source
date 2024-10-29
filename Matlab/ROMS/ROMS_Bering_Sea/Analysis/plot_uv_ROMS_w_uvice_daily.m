%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS uv with uvice daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'uv';
yyyy_all = 2019:2019;
mm_all = 1:1;
depth_shelf = 200; % m
layer = 45;

ispng = 0;
isgif = 1;

interval_model = 40;
scale_model = 2;

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/'];

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Figure
    h1 = figure; hold on;
    set(gcf, 'Position', [1 200 800 800])

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = ['Dsm2_spng_avg_', fstr, '.nc'];

            file_control = [filepath_control, filename];
            u = ncread(file_control,'u',[1 1 layer 1],[Inf Inf 1 1])';
            v = ncread(file_control,'v',[1 1 layer 1],[Inf Inf 1 1])';

            uice = ncread(file_control,'uice')';
            vice = ncread(file_control,'vice')';

            skip = 1;
            npts = [0 0 0 0];

            [ured,vred,lonred,latred,maskred] = uv_vec2rho(u,v,lon,lat,g.angle,g.mask_rho,skip,npts);
            ured = ured.*maskred;
            vred = vred.*maskred;
            speed = sqrt(ured.*ured + vred.*vred);

            [uicered,vicered,lonred,latred,maskred] = uv_vec2rho(uice,vice,lon,lat,g.angle,g.mask_rho,skip,npts);
            uicered = uicered.*maskred;
            vicered = vicered.*maskred;
            speed_ice = sqrt(uicered.*uicered + vicered.*vicered);

            timenum = datenum(yyyy,mm,dd);
            time_title = datestr(timenum, 'mmm dd, yyyy');

            % Figure title
            title(time_title, 'FontSize', 15);

            if mi == 1 && di == 1
                plot_map('Eastern_Bering', 'mercator', 'l')
                hold on;
                contourm(lat, lon, h, [50 200], 'Color', [.5 .5 .5]);

                qscale = quiverm(65, -160, 0, 1.*scale_model, 0);
                qscale(1).Color = 'k';
                qscale(2).Color = 'k';
                textm(64.5, -160, '1 m/s')
            else
                delete(q);
                delete(qice);
            end

            q = quiverm(latred(1:interval_model:end, 1:interval_model:end), ...
                lonred(1:interval_model:end, 1:interval_model:end), ...
                vred(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                ured(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

            q(1).Color = 'r';
            q(2).Color = 'r';

            qice = quiverm(latred(1:interval_model:end, 1:interval_model:end), ...
                lonred(1:interval_model:end, 1:interval_model:end), ...
                vicered(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                uicered(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

            qice(1).Color = 'b';
            qice(2).Color = 'b';

            l = legend([q(1), qice(1)], 'Surface velocity', 'Ice velocity');
            l.Location = 'SouthWest';
            l.FontSize = 20;

            pause(1)
            if ispng == 1
                print(['uv_ROMS_w_uvice_', datestr(timenum, 'yyyymmdd')],'-dpng');
            end

            if isgif == 1
                % Make gif
                gifname = ['uv_ROMS_w_uvice_', datestr(timenum, 'yyyymm'), '.gif'];

                frame = getframe(h1);
                im = frame2im(frame);
                [imind,cm] = rgb2ind(im,256);
                if mi == 1 && di == 1
                    imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
                else
                    imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
                end
            end

        end % di
    end % mi
end % yi