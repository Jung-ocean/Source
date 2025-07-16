%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS uv vector at surface and 50 m depth monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

vari_str = 'uv';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

% Load grid information
g = grd('BSf');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/monthly/'];

% Figure properties
interval_model = 20;
scale_model = 0.1;
skip = 1;
npts = [0 0 0 0];

color = 'jet';
climit = [0 20];
unit = 'cm/s';
savename = 'uv_surf_and_50m_w_speed';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;
scale_FS = 8;

figure;
set(gcf, 'Position', [1 200 1500 600])
t = tiledlayout(2,4);
% Figure title
title(t, ['uv with speed (surface and 50 m)'], 'FontSize', 25);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = ['Dsm2_spng_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    u = ncread(file, 'u'); 
    u = permute(u, [3 2 1]);
    v = ncread(file, 'v');
    v = permute(v, [3 2 1]);
    zeta = ncread(file, 'zeta')';
    z_r = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    
    u_rho = NaN([g.N, size(g.mask_rho)]);
    v_rho = NaN([g.N, size(g.mask_rho)]);
    for ni = 1:g.N
        u_tmp = squeeze(u(ni,:,:));
        v_tmp = squeeze(v(ni,:,:));

        [u_tmp2,v_tmp2,lonred,latred,maskred] = uv_vec2rho(u_tmp,v_tmp,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
        u_rho(ni,:,:) = u_tmp2.*maskred;
        v_rho(ni,:,:) = v_tmp2.*maskred;
    end

    u_surf = squeeze(u_rho(g.N,:,:))*100;
    v_surf = squeeze(v_rho(g.N,:,:))*100;
    speed_surf = sqrt(u_surf.*u_surf + v_surf.*v_surf);

    u_50m = vinterp(u_rho,z_r,-50)*100;
    v_50m = vinterp(v_rho,z_r,-50)*100;
    speed_50m = sqrt(u_50m.*u_50m + v_50m.*v_50m);

    % Surface plot
    nexttile(yi); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    p = pcolorm(g.lat_rho, g.lon_rho, speed_surf); shading flat
    colormap(flipud(pink))
    uistack(p, 'bottom');
    caxis([climit]);
    plot_map(map, 'mercator', 'l')

    q = quiverm(g.lat_rho(1:interval_model:end, 1:interval_model:end), ...
                g.lon_rho(1:interval_model:end, 1:interval_model:end), ...
                v_surf(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                u_surf(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

    q(1).Color = [0 0.4471 0.7412];
    q(2).Color = [0 0.4471 0.7412];

    textm(text1_lat, text1_lon, 'Surf', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    qscale = quiverm(64, -184.5, 0.*scale_model, 20.*scale_model, 0);
    qscale(1).Color = 'r';
    qscale(2).Color = 'r';
    tscale = textm(63.5, -184.5, '20 cm/s', 'Color', 'r', 'FontSize', scale_FS);

    if yi == 4
        c = colorbar;
        c.Layout.Tile = 'east';
        c.Title.String = unit;
    end

    % 50 m plot
    nexttile(yi+4); hold on;

    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

    p = pcolorm(g.lat_rho, g.lon_rho, speed_50m); shading flat
    colormap(flipud(pink))
    uistack(p, 'bottom');
    caxis([climit]);
    plot_map(map, 'mercator', 'l')

    q = quiverm(g.lat_rho(1:interval_model:end, 1:interval_model:end), ...
                g.lon_rho(1:interval_model:end, 1:interval_model:end), ...
                v_50m(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                u_50m(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

    q(1).Color = [0 0.4471 0.7412];
    q(2).Color = [0 0.4471 0.7412];

    textm(text1_lat, text1_lon, '50 m', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    qscale = quiverm(64, -184.5, 0.*scale_model, 20.*scale_model, 0);
    qscale(1).Color = 'r';
    qscale(2).Color = 'r';
    tscale = textm(63.5, -184.5, '20 cm/s', 'Color', 'r', 'FontSize', scale_FS);
    
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', mstr, '_monthly'],'-dpng');