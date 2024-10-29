clear; clc; close all

vari_str = 'latent';

yyyymm_all = [datenum(2018,11:12,15) datenum(2019,1:6,15)];

filepath_all = '/data/jungjih/ROMS_BSf/Output/Multi_year/';

con = 'Dsm2_spng';
exp = 'Dsm4_phi3m1';

% Read ROMS grid
g = grd('BSf');

switch vari_str
    case 'shflux'
        climit = [-200 200];
        contour_interval = [climit(1):50:climit(end)];
        unit = 'W/m^2';
        title_str = 'Surface net heat flux';
    case 'lwrad'
        vari_str_ERA5 = 'msnlwrf';
        climit = [-100 100];
        contour_interval = [climit(1):20:climit(end)];
        unit = 'W/m^2';
        title_str = 'Surface net longwave radiation flux';
    case 'sensible'
        vari_str_ERA5 = 'msshf';
        climit = [-100 100];
        contour_interval = [climit(1):20:climit(end)];
        unit = 'W/m^2';
        title_str = 'Surface sensible heat flux';
    case 'latent'
        vari_str_ERA5 = 'mslhf';
        climit = [-100 100];
        contour_interval = [climit(1):20:climit(end)];
        unit = 'W/m^2';
        title_str = 'Surface latent heat flux';
end

figure; hold on;
set(gcf, 'Position', [1 200 1800 450])
t = tiledlayout(1,3);
for yi = 1:length(yyyymm_all)
    yyyymm = yyyymm_all(yi);

    title(t, [title_str, ' (', datestr(yyyymm, 'mmm, yyyy'), ')'], 'FontSize', 25)

    % ERA5
    ERA5_filepath = ['/data/jungjih/Models/ERA5/monthly/'];
    ERA5_filename = ['ERA5_', datestr(yyyymm, 'yyyymm'), '.nc'];
    ERA5_file = [ERA5_filepath, ERA5_filename];
    lon_ERA5 = double(ncread(ERA5_file, 'longitude'));
    lat_ERA5 = double(ncread(ERA5_file, 'latitude'));

    if strcmp(vari_str, 'shflux')
        latent = ncread(ERA5_file, 'mslhf')';
        sensible = ncread(ERA5_file, 'msshf')';
        lwrad = ncread(ERA5_file, 'msnlwrf')';
        swrad = ncread(ERA5_file, 'msnswrf')';
        
        vari_ERA5 = swrad + lwrad + latent + sensible;
    else
        vari_ERA5 = ncread(ERA5_file, vari_str_ERA5)';
    end

    index1 = find(lon_ERA5 < 0);
    index2 = find(lon_ERA5 > 0);

    lon_ERA5 = [lon_ERA5(index2)-360; lon_ERA5(index1)];
    vari_ERA5 = [vari_ERA5(:,index2) vari_ERA5(:,index1)];

    % ROMS con
    con_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', con, '/monthly/'];
    con_filename = [con, '_', datestr(yyyymm, 'yyyymm'), '.nc'];
    con_file = [con_filepath, con_filename];
    vari_con = squeeze(ncread(con_file, vari_str))';

    % ROMS exp
    exp_filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
    exp_filename = [exp, '_', datestr(yyyymm, 'yyyymm'), '.nc'];
    exp_file = [exp_filepath, exp_filename];
    vari_exp = squeeze(ncread(exp_file, vari_str))';

    % Plot
    ax1 = nexttile(1);
    if yi == 1
        plot_map('Bering', 'mercator', 'l')
    else
        delete(p1);
        delete(h1);
    end
    p1 = pcolorm(lat_ERA5, lon_ERA5, vari_ERA5); shading flat
    colormap redblue
    plot_map('Bering', 'mercator', 'l')
    caxis(climit);
    [c1,h1] = contourm(lat_ERA5, lon_ERA5, vari_ERA5, contour_interval, 'k');

    title(['ERA5'])

    ax2 = nexttile(2);
    if yi == 1
        plot_map('Bering', 'mercator', 'l')
    else
        delete(p2)
        delete(h2)
    end
    p2 = pcolorm(g.lat_rho, g.lon_rho, vari_con.*g.mask_rho./g.mask_rho); shading flat
    colormap redblue
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
    colormap redblue
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

    print(['cmp_', vari_str, '_ROMS_to_ERA5_ROMS_monthly_', datestr(yyyymm, 'yyyymm')] ,'-dpng')
end