clear; clc; close all

region = 'US_west_NANOOS';
model = 'LiveOcean';

[lon_lim, lat_lim] = load_domain(region);

g = grd(model);
mask = g.mask_rho./g.mask_rho;
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));
F.ExtrapolationMethod = 'none';

go = grd('Oregon_1km');

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

figure;
set(gcf, 'Position', [1 200 1300 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'tight';

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    title(t, {datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ''}, 'FontSize', 25)

    % Satellite
    [lon_sat, lat_sat, ADT_sat] = load_ADT_CMEMS_monthly(yyyy,mm);
    lonind = find(lon_sat > lon_lim(1)-1 & lon_sat < lon_lim(2)+1);
    latind = find(lat_sat > lat_lim(1)-1 & lat_sat < lat_lim(2)+1);
    [lat_sat, lon_sat] = meshgrid(double(lat_sat(latind)), double(lon_sat(lonind)));
    ADT_sat = ADT_sat(lonind,latind)*100; % m to cm

    F.Values = g.h(:);
    h_interp = F(lat_sat,lon_sat);
    index = find(h_interp < 200);

    ADT_sat = ADT_sat - mean(ADT_sat(index), 'omitnan');

    % Model
    zeta_ROMS = load_models_2d_monthly(model, '', 'zeta', g.N, yyyy, mm);
    zeta_ROMS = zeta_ROMS.*mask.*100; % m to cm
    F.Values = zeta_ROMS(:);
    zeta_interp = F(lat_sat,lon_sat);
    zeta_ROMS = zeta_ROMS - mean(zeta_interp(index), 'omitnan');
    zeta_interp = zeta_interp - mean(zeta_interp(index), 'omitnan');

    ax1 = nexttile(1);
    if mi == 1
        plot_map(region, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    po = pcolorm(lat_sat, lon_sat, ADT_sat);
    colormap(jet(30))
    uistack(po, 'bottom')
    caxis([-30 30])
    title({'CMEMS L4', '(zero mean)'}, 'FontSize', 15)

    ax2 = nexttile(2);
    if mi == 1
        plot_map(region, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pm = pcolorm(lat_ROMS, lon_ROMS, zeta_ROMS);
    colormap(jet(30))
    uistack(pm, 'bottom')
    caxis([-30 30])
    c = colorbar;
    c.Title.String = 'cm';
    c.FontSize = 15;
    c.Ticks = -30:6:30;
    title({model, '(zero mean)'}, 'FontSize', 15)
    plabel('off')

    lonmin = min(go.lon_rho(:));
    lonmax = max(go.lon_rho(:));
    latmin = min(go.lat_rho(:))+.01;
    latmax = max(go.lat_rho(:));
    plotm([latmin, latmax latmax latmin latmin], [lonmin, lonmin, lonmax, lonmax, lonmin], '--k', 'LineWidth', 2);

    ax3 = nexttile(3);
    if mi == 1
        plot_map(region, 'mercator', 'l')
        contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    end
    pd = pcolorm(lat_sat, lon_sat, zeta_interp - ADT_sat);
    climit = [-20 20];
    interval = 2;
    [color, contour_interval] = get_color('redblue', climit, interval);
    colormap(ax3,color)
    uistack(pd, 'bottom')
    caxis(climit)
    c = colorbar;
    c.Title.String = 'cm';
    c.FontSize = 15;
    c.Ticks = climit(1):4:climit(end);
    title('Difference', 'FontSize', 15)
    plabel('off')

    plotm([latmin, latmax latmax latmin latmin], [lonmin, lonmin, lonmax, lonmax, lonmin], '--k', 'LineWidth', 2);

    print(['cmp_ADT_CMEMS_', model, '_', ystr, mstr], '-dpng')

    delete(po); delete(pm); delete(pd);
end