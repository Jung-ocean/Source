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

    [lon_sat, lat_sat, SST_sat] = load_MODIS_monthly(yyyy,mm);
    lonind = find(lon_sat > min(lon_ROMS(:))-1 & lon_sat < max(lon_ROMS(:))+1);
    latind = find(lat_sat > min(lat_ROMS(:))-1 & lat_sat < max(lat_ROMS(:))+1);
    [lat_sat, lon_sat] = meshgrid(lat_sat(latind), lon_sat(lonind));
    SST_sat = SST_sat(lonind,latind);
    
    filename = ['monthly_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    SST_ROMS = ncread(file, 'temp', [1 1 g.N 1], [Inf Inf 1 1]);
    F.Values = SST_ROMS(:);
    SST_interp = F(lat_sat,lon_sat);

    figure;
    set(gcf, 'Position', [1 200 800 800])
    t = tiledlayout(1,3);
    t.Padding = 'compact';
    t.TileSpacing = 'tight';
    title(t, {datestr(datenum(yyyy,mm,15), 'mmm, yyyy'), ''}, 'FontSize', 25)

    ax1 = nexttile(1);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_sat, lon_sat, SST_sat);
    colormap(jet(14))
    uistack(po, 'bottom')
    caxis([6 20])
    title('MODIS', 'FontSize', 15)

    ax2 = nexttile(2);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_ROMS, lon_ROMS, SST_ROMS);
    colormap(jet(14))
    uistack(po, 'bottom')
    caxis([6 20])
    c = colorbar;
    c.Title.String = '^oC';
    c.FontSize = 15;
    title('ROMS', 'FontSize', 15)
    plabel('off')

    ax3 = nexttile(3);
    plot_map('Oregon', 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    po = pcolorm(lat_sat, lon_sat, SST_interp - SST_sat);
    climit = [-3 3];
    interval = .25;
    [color, contour_interval] = get_color('redblue', climit, interval);
    colormap(ax3,color)
    uistack(po, 'bottom')
    caxis(climit)
    c = colorbar;
    c.Title.String = '^oC';
    c.FontSize = 15;
    c.Ticks = climit(1):1:climit(end);
    title('Difference', 'FontSize', 15)
    plabel('off')

    print(['cmp_SST_MODIS_', ystr, mstr], '-dpng')
end