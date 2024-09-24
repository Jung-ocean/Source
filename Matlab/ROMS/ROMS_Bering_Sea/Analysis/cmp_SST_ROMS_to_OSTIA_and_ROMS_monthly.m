clear; clc; close all

vari_str = 'temp';

yyyymm_all = [datenum(2018,11:12,15) datenum(2019,1:6,15)];

filepath_all = '/data/jungjih/ROMS_BSf/Output/Multi_year/';

con = 'Dsm2_spng';
exp = 'Dsm4_phi3m1';

% Read ROMS grid
g = grd('BSf');

climit = [0 10];
contour_interval = [climit(1):2:climit(end)];
unit = '^oC';

figure; hold on;
set(gcf, 'Position', [1 200 1800 450])
t = tiledlayout(1,3);
for yi = 1:length(yyyymm_all)
    yyyymm = yyyymm_all(yi);

    title(t, ['SST (', datestr(yyyymm, 'mmm, yyyy'), ')'], 'FontSize', 25)

    % OSTIA
    OSTIA_filepath = ['/data/jungjih/Observations/Satellite_SST/OSTIA/monthly/'];
    OSTIA_filename = ['OSTIA_', datestr(yyyymm, 'yyyymm'), '.nc'];
    OSTIA_file = [OSTIA_filepath, OSTIA_filename];
    lon_OSTIA = double(ncread(OSTIA_file, 'lon'));
    lat_OSTIA = double(ncread(OSTIA_file, 'lat'));
    vari_OSTIA = ncread(OSTIA_file, 'analysed_sst')' - 273.15; % K to dec C

    index1 = find(lon_OSTIA < 0);
    index2 = find(lon_OSTIA > 0);

    lon_OSTIA = [lon_OSTIA(index2)-360; lon_OSTIA(index1)];
    vari_OSTIA = [vari_OSTIA(:,index2) vari_OSTIA(:,index1)];

    index_lat = find(lat_OSTIA > min(g.lat_rho(:))-1 & lat_OSTIA < max(g.lat_rho(:)) + 1);
    index_lon = find(lon_OSTIA > min(g.lon_rho(:))-1 & lon_OSTIA < max(g.lon_rho(:)) + 1);
    lat_OSTIA = lat_OSTIA(index_lat);
    lon_OSTIA = lon_OSTIA(index_lon);
    vari_OSTIA = vari_OSTIA(index_lat, index_lon);

    % ROMS con
    con_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', con, '/monthly/'];
    con_filename = [con, '_', datestr(yyyymm, 'yyyymm'), '.nc'];
    con_file = [con_filepath, con_filename];
    vari_con = squeeze(ncread(con_file, vari_str, [1 1 g.N 1], [Inf Inf 1 Inf]))';

    % ROMS exp
    exp_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
    exp_filename = [exp, '_', datestr(yyyymm, 'yyyymm'), '.nc'];
    exp_file = [exp_filepath, exp_filename];
    vari_exp = squeeze(ncread(exp_file, vari_str, [1 1 g.N 1], [Inf Inf 1 Inf]))';

    % Plot
    ax1 = nexttile(1);
    if yi == 1
        plot_map('Bering', 'mercator', 'l')
    else
        delete(p1);
        delete(h1);
    end
    p1 = pcolorm(lat_OSTIA, lon_OSTIA, vari_OSTIA); shading flat
    plot_map('Bering', 'mercator', 'l')
    caxis(climit);
    [c1,h1] = contourm(lat_OSTIA, lon_OSTIA, vari_OSTIA, contour_interval, 'k');

    title(['OSTIA'])

    ax2 = nexttile(2);
    if yi == 1
        plot_map('Bering', 'mercator', 'l')
    else
        delete(p2)
        delete(h2)
    end
    p2 = pcolorm(g.lat_rho, g.lon_rho, vari_con.*g.mask_rho./g.mask_rho); shading flat
    plot_map('Bering', 'mercator', 'l')
    caxis(climit);
    vari_con_contour = vari_con;
    vari_con_contour(isnan(vari_con_contour) == 1) = -5000;
    [c2,h2] = contourm(g.lat_rho, g.lon_rho, vari_con_contour, contour_interval, 'k');
    title(['ROMS ', con], 'Interpreter', 'none')

    ax3 = nexttile(3);
    if yi == 1
        plot_map('Bering', 'mercator', 'l')
    else
        delete(p3)
        delete(h3)
    end
    p3 = pcolorm(g.lat_rho, g.lon_rho, vari_exp.*g.mask_rho./g.mask_rho); shading flat
    plot_map('Bering', 'mercator', 'l')
    caxis(climit);
    vari_exp_contour = vari_exp;
    vari_exp_contour(isnan(vari_exp_contour) == 1) = -5000;
    [c3,h3] = contourm(g.lat_rho, g.lon_rho, vari_exp_contour, contour_interval, 'k');
    cb = colorbar;
    cb.Title.String = unit;
    title(['ROMS ', exp], 'Interpreter', 'none')

    t.TileSpacing = 'compact';
    t.Padding = 'compact';

    set(gcf, 'Position', [1 200 1800 450])

    print(['cmp_SST_ROMS_to_ERA5_ROMS_monthly_', datestr(yyyymm, 'yyyymm')] ,'-dpng')
end