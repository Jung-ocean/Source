%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS aice with vel to NSIDC data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'aice';
yyyy = 2022;
mm_all = 1:2;
region = 'Gulf_of_Anadyr';

ispng = 0;
isgif = 1;

interval_model = 10;
scale_model = 0.01;
scale_NSIDC = 0.1;

% Model
filepath_all = ['/data/sdurski/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/'];

% Load grid information
g = grd('BSf');
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

% NSIDC
ystr = num2str(yyyy);
filepath_concentration = ['/data/jungjih/Observations/Sea_ice/NSIDC/'];
filename_concentration = ['aice_NSIDC_', ystr, '.mat'];
file_concentration = [filepath_concentration, filename_concentration];
load(file_concentration)
lon_NSIDC = lon;
lat_NSIDC = lat;
aice_NSIDC = aice;

filepath_vel = ['/data/smithj28/Obersvations/NSIDC_Ice_Motion/'];
filename_vel = ['icemotion_daily_nh_25km_', ystr, '0101_', ystr, '1231_v4.1.nc'];
file_vel = [filepath_vel, filename_vel];

lon_NSIDC_vel = double(ncread(file_vel, 'longitude'));
lat_NSIDC_vel = double(ncread(file_vel, 'latitude'));
xvel_NSIDC = ncread(file_vel, 'u');
yvel_NSIDC = ncread(file_vel, 'v');

% Figure
h1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 650])
t = tiledlayout(1,2);

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        timenum = datenum(yyyy,mm,dd);
        time_title = datestr(timenum, 'mmm dd, yyyy');
        % Figure title
        title(t, time_title, 'FontSize', 25);

        % ROMS
        filenum = datenum(yyyy,mm,dd) - startdate + 1;
        fstr = num2str(filenum, '%04i');
        filename = ['Dsm2_spng_avg_', fstr, '.nc'];
        file = [filepath_control, filename];
        aice = ncread(file, 'aice')';
        uice = 100*ncread(file, 'uice')';
        vice = 100*ncread(file, 'vice')';

        nexttile(1)
        if mi == 1 && di == 1
            plot_map(region, 'mercator', 'l')
            hold on;

            qref = quiverm(66, -184, 0, 10*scale_model, 0);
            qref(1).Color = 'k';
            qref(2).Color = 'k';
            qt = textm(65.7, -184, '10 cm/s');
        else
            delete(pmodel);
            delete(qmodel)
        end

        pmodel = pcolorm(g.lat_rho,g.lon_rho,aice.*mask);
        uistack(pmodel,'bottom')
        caxis([0 1])

        skip = 1;
        npts = [0 0 0 0];

        [uicered,vicered,lonred,latred,maskred] = uv_vec2rho(uice,vice,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        uicered = uicered.*maskred;
        vicered = vicered.*maskred;

        index = find(aice < 0.05);
        uicered(index) = NaN;
        vicered(index) = NaN;
                
        qmodel = quiverm(latred(1:interval_model:end, 1:interval_model:end), ...
            lonred(1:interval_model:end, 1:interval_model:end), ...
            vicered(1:interval_model:end, 1:interval_model:end).*scale_model, ...
            uicered(1:interval_model:end, 1:interval_model:end).*scale_model, ...
            0);

        qmodel(1).Color = 'k';
        qmodel(2).Color = 'k';

        title(['ROMS'], 'Interpreter', 'None')

        % NSIDC
        nexttile(2);

        if mi == 1 && di == 1
            plot_map(region, 'mercator', 'l')
            hold on;

            qref = quiverm(66, -184, 0, 10*scale_NSIDC, 0);
            qref(1).Color = 'k';
            qref(2).Color = 'k';
            qt = textm(65.7, -184, '10 cm/s');
        else
            delete(pnsidc);
            delete(qnsidc);
        end

        YTD = datenum(yyyy,mm,dd) - datenum(yyyy,1,1) + 1;
        aice_NSIDC_day = squeeze(aice_NSIDC(YTD,:,:));
        xvel_day = double(squeeze(xvel_NSIDC(:,:,YTD)));
        yvel_day = double(squeeze(yvel_NSIDC(:,:,YTD)));

        pnsidc = pcolorm(lat_NSIDC,lon_NSIDC,aice_NSIDC_day);
        uistack(pnsidc,'bottom')
        caxis([0 1])
        if mi == 1 && di == 1
            c = colorbar;
        end

        u_NSIDC = [cosd(lon_NSIDC_vel).*xvel_day + sind(lon_NSIDC_vel).*yvel_day];
        v_NSIDC = [-sind(lon_NSIDC_vel).*xvel_day + cosd(lon_NSIDC_vel).*yvel_day];

        qnsidc = quiverm(lat_NSIDC_vel, lon_NSIDC_vel, v_NSIDC.*scale_NSIDC, u_NSIDC.*scale_NSIDC, 0);
        qnsidc(1).Color = 'k';
        qnsidc(2).Color = 'k';

        title(['NSIDC'])


        t.TileSpacing = 'compact';
        t.Padding = 'compact';

        pause(1)

        if ispng == 1
            print(['cmp_aice_w_vel_to_NSIDC_daily_', datestr(timenum, 'yyyymmdd')],'-dpng');
        end

        if isgif == 1
            % Make gif
            gifname = ['cmp_aice_w_vel_to_NSIDC_daily_', datestr(timenum, 'yyyy'), '.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if mi == 1 && di == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end
        end

        disp([ystr, mstr, dstr, '...'])
    end % di
end % mi