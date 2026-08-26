clear; clc; close all

expname = 'LiveOcean';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_', expname])

g = grd('Oregon_1km');
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));
F.ExtrapolationMethod = 'none';

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

filepath = ['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Outputs/Output_', expname, '/monthly/'];

figure;
set(gcf, 'Position', [1 200 800 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    title(t, {datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ''}, 'FontSize', 25)

    [lat_sat, lon_sat, SSS_sat] = load_SSS_sat_2d_monthly('SMOS', 10, yyyy, mm);

    lonind = find(lon_sat > min(lon_ROMS(:))-1 & lon_sat < max(lon_ROMS(:))+1);
    latind = find(lat_sat > min(lat_ROMS(:))-1 & lat_sat < max(lat_ROMS(:))+1);
    [lat_sat, lon_sat] = meshgrid(lat_sat(latind), lon_sat(lonind));
    SSS_sat = SSS_sat(lonind,latind);
    
    filename = ['monthly_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    SSS_ROMS = ncread(file, 'salt', [1 1 g.N 1], [Inf Inf 1 1]);
    F.Values = SSS_ROMS(:);
    SSS_interp = F(lat_sat,lon_sat);

    ax1 = nexttile(1);
    if mi == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    po = pcolorm(lat_sat, lon_sat, SSS_sat);
    colormap(jet(14))
    uistack(po, 'bottom')
    caxis([20 34])
    title('SMOS', 'FontSize', 15)

    ax2 = nexttile(2);
    if mi == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pm = pcolorm(lat_ROMS, lon_ROMS, SSS_ROMS);
    colormap(jet(14))
    uistack(pm, 'bottom')
    caxis([20 34])
    c = colorbar;
    c.Title.String = 'psu';
    c.FontSize = 15;
    title('ROMS', 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    if mi == 1
        plot_map('Oregon', 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pd = pcolorm(lat_sat, lon_sat, SSS_interp - SSS_sat);
    climit = [-2 2];
    interval = .2;
    [color, contour_interval] = get_color('redblue', climit, interval);
    colormap(ax3,color)
    uistack(pd, 'bottom')
    caxis(climit)
    c = colorbar;
    c.Title.String = 'psu';
    c.FontSize = 15;
    c.Ticks = climit(1):1:climit(end);
    title('Difference', 'FontSize', 15)
    plabel('off')

    print(['cmp_SSS_SMOS_', ystr, mstr], '-dpng')

    delete(po); delete(pm); delete(pd);
end