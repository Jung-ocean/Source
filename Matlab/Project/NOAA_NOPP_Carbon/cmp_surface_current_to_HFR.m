clear; clc; close all

exp = 'Oregon_1km';
g = grd(exp);
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

filepath = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/monthly/';

figure;
set(gcf, 'Position', [1 200 900 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    % Load HFR data 
    [lon_HFR, lat_HFR, u_HFR, v_HFR] = load_HFR_monthly(yyyy,mm);

    lonind = find(lon_HFR > min(lon_ROMS(:))-1 & lon_HFR < max(lon_ROMS(:))+1);
    latind = find(lat_HFR > min(lat_ROMS(:))-1 & lat_HFR < max(lat_ROMS(:))+1);
    [lat_HFR, lon_HFR] = meshgrid(lat_HFR(latind), lon_HFR(lonind));
    u_HFR = u_HFR(lonind,latind);
    v_HFR = v_HFR(lonind,latind);

    u_ROMS = load_models_2d_monthly(exp, 'u', g.N, yyyy, mm)*100;
    v_ROMS = load_models_2d_monthly(exp, 'v', g.N, yyyy, mm)*100;
    
    skip = 1;
    npts = [0 0 0 0];
    [u_ROMS_rho,v_ROMS_rho,lonred,latred,maskred] = uv_vec2rho_J(u_ROMS,v_ROMS,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    u_ROMS_rho = u_ROMS_rho.*maskred;
    v_ROMS_rho = v_ROMS_rho.*maskred;

    F.Values = u_ROMS_rho(:);
    u_interp = F(lat_HFR,lon_HFR);

    F.Values = v_ROMS_rho(:);
    v_interp = F(lat_HFR,lon_HFR);

    ax1 = nexttile(1); cla;
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    interval = 3;
    q = plot_vectors('Oregon', lon_HFR, lat_HFR, u_HFR, v_HFR, interval, 'k', 1);
    title('Observation', 'FontSize', 15)

    ax2 = nexttile(2); cla;
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    interval = 18;
    q = plot_vectors('Oregon', lon_ROMS, lat_ROMS, u_ROMS_rho, v_ROMS_rho, interval, 'k', 0);
    title('ROMS', 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3); cla;
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    u_diff = u_interp - u_HFR;
    v_diff = v_interp - v_HFR;
    interval = 3;
    q = plot_vectors('Oregon', lon_HFR, lat_HFR, u_diff, v_diff, interval, 'k', 0);
    title('Difference', 'FontSize', 15)
    plabel('off')

    print(['cmp_surface_current_HFR_', ystr, mstr], '-dpng')
end

