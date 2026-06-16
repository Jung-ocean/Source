clear; clc; close all

g = grd('Oregon_1km');
lon_ROMS = g.lon_rho;
lat_ROMS = g.lat_rho;
F = scatteredInterpolant(lat_ROMS(:), lon_ROMS(:), 0.*lat_ROMS(:));

yyyy = 2024;
ystr = num2str(yyyy);
mm_all = 1:12;

filepath = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Output/monthly/';

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    [lon_sat, lat_sat, ADT_sat] = load_ADT_CMEMS_monthly(yyyy,mm);
    lonind = find(lon_sat > min(lon_ROMS(:))-1 & lon_sat < max(lon_ROMS(:))+1);
    latind = find(lat_sat > min(lat_ROMS(:))-1 & lat_sat < max(lat_ROMS(:))+1);
    [lat_sat, lon_sat] = meshgrid(double(lat_sat(latind)), double(lon_sat(lonind)));
    ADT_sat = ADT_sat(lonind,latind)*100; % m to cm
    ADT_sat = ADT_sat - mean(ADT_sat(:), 'omitnan');

    filename = ['monthly_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    zeta_ROMS = ncread(file, 'zeta')*100; % m to cm
    zeta_ROMS = zeta_ROMS - mean(zeta_ROMS(:), 'omitnan');
    F.Values = zeta_ROMS(:);
    zeta_interp = F(lat_sat,lon_sat);

    figure;
    set(gcf, 'Position', [1 200 800 800])
    t = tiledlayout(1,3);
    t.Padding = 'compact';
    t.TileSpacing = 'tight';
    title(t, {datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ''}, 'FontSize', 25)

    ax1 = nexttile(1);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_sat, lon_sat, ADT_sat);
    colormap(jet(20))
    uistack(po, 'bottom')
    caxis([-20 20])
    title({'CMEMS L4', '(zero mean)'}, 'FontSize', 15)

    ax2 = nexttile(2);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_ROMS, lon_ROMS, zeta_ROMS);
    colormap(jet(20))
    uistack(po, 'bottom')
    caxis([-20 20])
    c = colorbar;
    c.Title.String = 'cm';
    c.FontSize = 15;
    c.Ticks = -20:4:20;
    title({'ROMS', '(zero mean)'}, 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_sat, lon_sat, zeta_interp - ADT_sat);
    climit = [-10 10];
    interval = 1;
    [color, contour_interval] = get_color('redblue', climit, interval);
    colormap(ax3,color)
    uistack(po, 'bottom')
    caxis(climit)
    c = colorbar;
    c.Title.String = 'cm';
    c.FontSize = 15;
    c.Ticks = climit(1):2:climit(end);
    title('Difference', 'FontSize', 15)
    plabel('off')

    print(['cmp_ADT_CMEMS_', ystr, mstr], '-dpng')
end