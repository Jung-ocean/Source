clear; clc; close all

domain = 'Oregon_1km_large';
expname = 'LiveOcean_nudg';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/', domain, '/Results/Output_', expname])

g = grd(domain);
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
    title(t, {datestr(timenum, 'mm-dd-yyyy'),''}, 'FontSize', 15);

    % Load ODYSSEA data
    [lon_sat, lat_sat, SST_sat] = load_ODYSSEA_daily(timenum);

    lonind = find(lon_sat > min(lon_ROMS(:))-1 & lon_sat < max(lon_ROMS(:))+1);
    latind = find(lat_sat > min(lat_ROMS(:))-1 & lat_sat < max(lat_ROMS(:))+1);
    [lat_sat, lon_sat] = meshgrid(lat_sat(latind), lon_sat(lonind));
    SST_sat = SST_sat(lonind,latind);
    
    SST_ROMS = load_models_2d_daily(domain, expname, 'temp', g.N, timenum);

    F.Values = SST_ROMS(:);
    SST_interp = F(lat_sat,lon_sat);

    ax1 = nexttile(1);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    po = pcolorm(lat_sat, lon_sat, SST_sat);
    colormap(jet(14))
    uistack(po, 'bottom')
    caxis([6 20])
    title('ODYSSEA', 'FontSize', 15)

    ax2 = nexttile(2);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pm = pcolorm(lat_ROMS, lon_ROMS, SST_ROMS);
    colormap(jet(14))
    uistack(pm, 'bottom')
    caxis([6 20])
    c = colorbar;
    c.Title.String = '^oC';
    c.FontSize = 15;
    title('ROMS', 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    if di == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pd = pcolorm(lat_sat, lon_sat, SST_interp - SST_sat);
    climit = [-3 3];
    interval = .25;
    [color, contour_interval] = get_color('redblue', climit, interval);
    colormap(ax3,color)
    uistack(pd, 'bottom')
    caxis(climit)
    c = colorbar;
    c.Title.String = '^oC';
    c.FontSize = 15;
    c.Ticks = climit(1):1:climit(end);
    title('Difference', 'FontSize', 15)
    plabel('off')

    % Make gif
    gifname = ['cmp_SST_ODYSSEA_', ystr, mstr, '.gif'];

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if di == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(po);
    delete(pm);
    delete(pd);
end

