%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS vertical section to Argo data monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'salt';
yyyy = 2022; ystr = num2str(yyyy);
mm_all = 1:12;

num_hori = 40;
chk_sec = 0;

lon_sec = [-180 -170];
lat_sec = [56 60];

ylimit = [-1000 0];

switch vari_str
    case 'temp'
        climit_model = [0 15];
        climit_obs = climit_model;
        cinterval = 2;
        contour_interval = 2;
        unit = '^oC';
        vari_str_obs = 'temp';
    case 'salt'
        climit_model = [31.5 35];
        climit_obs = climit_model;
        cinterval = 0.5;
        contour_interval = 0.2;
        unit = 'g/kg';
        vari_str_obs = 'salt';
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
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

% Vertical section setting
lon_interp = linspace(lon_sec(1), lon_sec(2), num_hori);
lat_interp = linspace(lat_sec(1), lat_sec(2), num_hori);
lon_plot = repmat(lon_interp, [g.N, 1]);

if chk_sec == 1
    figure; hold on;
    plot_map('Bering', 'mercator', 'l')
    hold on;
    contourm(lat, lon, h, [50 200], 'k');
    plotm(lat_interp, lon_interp, '.r');

    print('chk_sec','-dpng')
    close all
end

% Argo
filepath_Argo = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];

% Figure
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1800 650])
t = tiledlayout(1,2);

for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath_control, filename];
    vari_control = ncread(file, vari_str);
    vari_control = permute(vari_control, [3 2 1]);
    zeta = ncread(file, 'zeta')';

    z = zlevs(h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);

    timenum = datenum(yyyy,mm,15);
    time_title = datestr(timenum, 'mmm, yyyy');

    % Figure title
    title(t, time_title, 'FontSize', 25);

    vari_sec = [];
    z_sec = [];
    for ni = 1:g.N
        vari_tmp = squeeze(vari_control(ni,:,:));
        z_tmp = squeeze(z(ni,:,:));
        vari_sec(ni,:) = interp2(g.lon_rho, g.lat_rho, vari_tmp, lon_interp, lat_interp);
        z_sec(ni,:) = interp2(g.lon_rho, g.lat_rho, z_tmp, lon_interp, lat_interp);
    end

    nexttile(1); cla; hold on

    p1 = pcolor(lon_plot,z_sec,vari_sec); shading interp
    [cs1, h1] = contour(lon_plot,z_sec,vari_sec, [climit_model(1):contour_interval:climit_model(end)], 'k');
    xlabel('Longitude');
    ylabel('Depth (m)')
    clabel(cs1, h1, 'FontSize', 15, 'LabelSpacing', 200);
    ylim(ylimit)
    caxis(climit_model)
    if mi == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = [climit_model(1):cinterval:climit_model(end)];
    end
    set(gca, 'FontSize', 12)
    title(['ROMS'], 'Interpreter', 'None')

    % Argo
    filepath_obs = filepath_Argo;
    filepattern_obs = fullfile(filepath_obs, (['*', ystr, '_', mstr, '*.mat']));
    filename_obs = dir(filepattern_obs);

    file_obs = [filepath_obs, filename_obs.name];
    obs = load(file_obs);

    lon_obs = obs.lon'-360;
    lat_obs = obs.lat';
    vari_obs = eval(['obs.', vari_str_obs]);
    vari_obs = permute(vari_obs, [3 2 1]);
    vari_depth = -obs.pres;

    z_sec_obs = repmat(vari_depth, [1, num_hori]);
    lon_plot_obs = repmat(lon_interp, [length(vari_depth), 1]);

    vari_sec_obs = [];
    for ni = 1:length(vari_depth)
        vari_tmp = squeeze(vari_obs(ni,:,:));
        vari_sec_obs(ni,:) = interp2(lon_obs, lat_obs, vari_tmp, lon_interp, lat_interp);
    end

    % Tile
    nexttile(2); cla; hold on

    p2 = pcolor(lon_plot_obs,z_sec_obs,vari_sec_obs); shading interp
    [cs2, h2] = contour(lon_plot_obs,z_sec_obs,vari_sec_obs, [climit_obs(1):contour_interval:climit_obs(end)], 'k');
    clabel(cs2, h2, 'FontSize', 15, 'LabelSpacing', 200);
    ylim(ylimit)
    caxis(climit_obs)
    if mi == 1
        c = colorbar;
        c.Title.String = unit;
        c.Ticks = [climit_model(1):cinterval:climit_model(end)];
    end
    set(gca, 'FontSize', 12)
    title('Argo (BOA)', 'Interpreter', 'None')

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    pause(1)
    %         print(['cmp_vert_', vari_str, '_Argo_monthly_', datestr(timenum, 'yyyymm')],'-dpng');

    % Make gif
    gifname = ['cmp_vert_', vari_str, '_Argo_monthly_', ystr, '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if mi == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    disp([ystr, mstr, '...'])
end % mi
