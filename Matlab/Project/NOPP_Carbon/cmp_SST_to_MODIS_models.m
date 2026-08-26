clear; clc; close all

region = 'Oregon';
model = 'LiveOcean';

[lon_lim, lat_lim] = load_domain(region);

g = grd(model);
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));
F.ExtrapolationMethod = 'none';

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

figure;
set(gcf, 'Position', [1 200 800 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    title(t, {datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ''}, 'FontSize', 25)

    [lon_sat, lat_sat, SST_sat] = load_MODIS_monthly(yyyy,mm);
    lonind = find(lon_sat > lon_lim(1)-1 & lon_sat < lon_lim(2)+1);
    latind = find(lat_sat > lat_lim(1)-1 & lat_sat < lat_lim(2)+1);
    [lat_sat, lon_sat] = meshgrid(lat_sat(latind), lon_sat(lonind));
    SST_sat = SST_sat(lonind,latind);
  
    SST_ROMS = load_models_2d_monthly(model, 'temp', g.N, yyyy, mm);
    F.Values = SST_ROMS(:);
    SST_interp = F(lat_sat,lon_sat);

    ax1 = nexttile(1);
    if mi == 1
        plot_map(region, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    po = pcolorm(lat_sat, lon_sat, SST_sat);
    colormap(jet(14))
    uistack(po, 'bottom')
    caxis([6 20])
    title('MODIS', 'FontSize', 15)

    ax2 = nexttile(2);
    if mi == 1
        plot_map(region, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pm = pcolorm(lat_ROMS, lon_ROMS, SST_ROMS);
    colormap(jet(14))
    uistack(pm, 'bottom')
    caxis([6 20])
    c = colorbar;
    c.Title.String = '^oC';
    c.FontSize = 15;
    title(model, 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    if mi ==1
        plot_map(region, 'mercator', 'l')
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

    print(['cmp_SST_MODIS_', model, '_', ystr, mstr], '-dpng')

    delete(po); delete(pm); delete(pd);
end