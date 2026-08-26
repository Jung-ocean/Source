clear; clc; close all

expname = 'LiveOcean_nudg_ERA5';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_', expname])

model = 'Oregon_1km';
g = grd(model);
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));

yyyy = 2024;
ystr = num2str(yyyy);
mm = 7;
mstr = num2str(mm, '%02i');

f1 = figure;
set(gcf, 'Position', [1 200 900 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for di = 1:eomday(yyyy,mm)
    dd = di;

    timenum = datenum(yyyy,mm,dd);
    title(t, datestr(timenum, 'mm-dd-yyyy'), 'FontSize', 15);

    % Load HFR data
    [lon_HFR, lat_HFR, u_HFR, v_HFR] = load_HFR_daily(timenum);

    lonind = find(lon_HFR > min(lon_ROMS(:))-1 & lon_HFR < max(lon_ROMS(:))+1);
    latind = find(lat_HFR > min(lat_ROMS(:))-1 & lat_HFR < max(lat_ROMS(:))+1);
    [lat_HFR, lon_HFR] = meshgrid(lat_HFR(latind), lon_HFR(lonind));
    u_HFR = u_HFR(lonind,latind);
    v_HFR = v_HFR(lonind,latind);

    u_ROMS = load_models_2d_daily(model, expname, 'u', g.N, timenum)*100;
    v_ROMS = load_models_2d_daily(model, expname, 'v', g.N, timenum)*100;

    skip = 1;
    npts = [0 0 0 0];
    [u_ROMS_rho,v_ROMS_rho,lonred,latred,maskred] = uv_vec2rho_J(u_ROMS,v_ROMS,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);
    u_ROMS_rho = u_ROMS_rho.*maskred;
    v_ROMS_rho = v_ROMS_rho.*maskred;

    F.Values = u_ROMS_rho(:);
    u_interp = F(lat_HFR,lon_HFR);

    F.Values = v_ROMS_rho(:);
    v_interp = F(lat_HFR,lon_HFR);

    ax1 = nexttile(1);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
        isscale = 1;
    else
        isscale = 0;
    end
    interval = 3;
    
    q1 = plot_vectors('Oregon', lon_HFR, lat_HFR, u_HFR, v_HFR, interval, 'k', isscale);
    title('Observation', 'FontSize', 15)

    ax2 = nexttile(2);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    interval = 18;
    q2 = plot_vectors('Oregon', lon_ROMS, lat_ROMS, u_ROMS_rho, v_ROMS_rho, interval, 'k', 0);
    title('ROMS', 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    u_diff = u_interp - u_HFR;
    v_diff = v_interp - v_HFR;
    interval = 3;
    q3 = plot_vectors('Oregon', lon_HFR, lat_HFR, u_diff, v_diff, interval, 'k', 0);
    title('Difference', 'FontSize', 15)
    plabel('off')

    % Make gif
    gifname = ['cmp_surface_current_HFR_', ystr, mstr, '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if di == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(q1);
    delete(q2);
    delete(q3);
end

