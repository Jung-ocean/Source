%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS hice to ICESat2 data monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'hice';
yyyy = 2022;
mm_all = 1:4;
region = 'Bering';

climit = [0 2];

ispng = 0;
isgif = 1;

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

% Load grid information
g = grd('BSf');
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

% ICESat2
filepath_ICESat2 = ['/data/jungjih/Observations/Sea_ice/ICESat2/Thickness/data/'];


% Figure
h1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

ystr = num2str(yyyy);
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    timenum = datenum(yyyy,mm,15);
    time_title = datestr(timenum, 'mmm, yyyy');
    % Figure title
    title(t, time_title, 'FontSize', 25);

    % ROMS
    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath_control, filename];
    hice = ncread(file, 'hice')';
    hice(hice == 0) = NaN;

    nexttile(1)
    if mi == 1
        plot_map(region, 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', 'k');
    else
        delete(pmodel);
    end

    pmodel = pcolorm(g.lat_rho,g.lon_rho,hice.*mask);
    uistack(pmodel,'bottom')
    caxis(climit)

    title(['ROMS'], 'Interpreter', 'None')

    % ICESat2
    nexttile(2);

    filename_ICESat2 = ['IS2SITMOGR4_01_', ystr, mstr, '_006_003.nc'];
    file_ICESat2 = [filepath_ICESat2, filename_ICESat2];

    if mi == 1
        plot_map(region, 'mercator', 'l')
        hold on;
        contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'Color', 'k');
    else
        delete(picesat2);
    end

    lon_ICESat2 = double(ncread(file_ICESat2, 'longitude')');
    lat_ICESat2 = double(ncread(file_ICESat2, 'latitude')');
    hice_ICESat2 = double(ncread(file_ICESat2, 'ice_thickness_int')');

    picesat2 = pcolorm(lat_ICESat2,lon_ICESat2,hice_ICESat2);
    uistack(picesat2,'bottom')
    caxis(climit)
    if mi == 1
        c = colorbar;
        c.Title.String = 'm';
    end

    title(['ICESat2'])

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    pause(1)

    if ispng == 1
        print(['cmp_hice_to_ICESat2_monthly_', datestr(timenum, 'yyyymm')],'-dpng');
    end

    if isgif == 1
        % Make gif
        gifname = ['cmp_hice_to_ICESat2_monthly_', datestr(timenum, 'yyyy'), '.gif'];

        frame = getframe(h1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
    end

    disp([ystr, mstr, '...'])
end % mi