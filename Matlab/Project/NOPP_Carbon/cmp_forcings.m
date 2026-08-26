clear; clc; close all

model = 'Oregon_1km';
expname = 'LiveOcean_nudg';
region = 'Oregon';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_', expname])

vari_str = 'swrad';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 7;
mstr = num2str(mm, '%02i');

switch vari_str
    case 'swrad'
        vari_ERA5 = 'msnswrf';
        vari_CFSv2 = 'DSWRF_surface';
        climit = [0 350];
        unit = 'W/m^2';
    case 'Vwind'
        vari_ERA5 = 'v10';
        vari_CFSv2 = 'VGRD_10maboveground';
        climit = [-10 10];
        unit = 'm/s';
    case 'Tair'
        vari_ERA5 = 't2m';
        vari_CFSv2 = 'TMP_2maboveground';
        climit = [5 20];
        unit = '^oC';
end

[lon_target, lat_target] = load_domain(region);

g = grd(model);

figure;
set(gcf, 'Position', [1 200 800 800])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';
title(t, {[vari_str, ', ', ystr, mstr], ''}, 'FontSize', 20)

% ERA5
[lon, lat, vari] = load_ERA5_monthly(yyyy, mm, vari_ERA5, lon_target, lat_target);
[lat2, lon2] = meshgrid(lat, lon);
if strcmp(vari_str, 'Tair')
    vari = vari-273.15;
end
nexttile(1);
plot_map(region, 'mercator', 'l');
pe = pcolorm(lat2, lon2, vari);
uistack(pe, 'bottom')
colormap(jet)
caxis(climit)
title('ERA5', 'FontSize', 20)

% CFSv2
[lon, lat, vari] = load_CFSv2_monthly(yyyy, mm, vari_CFSv2, lon_target, lat_target);
[lat2, lon2] = meshgrid(lat, lon);
if strcmp(vari_str, 'Tair')
    vari = vari-273.15;
end
nexttile(2);
plot_map(region, 'mercator', 'l');
pc = pcolorm(lat2, lon2, vari);
uistack(pc, 'bottom')
colormap(jet)
caxis(climit)
if strcmp(vari_str, 'swrad')
    title('CFSv2 (down)', 'FontSize', 20)
else
    title('CFSv2', 'FontSize', 20)
end

plabel('off')

% ROMS
vari = load_models_2d_monthly(model, expname, vari_str, 45, yyyy, mm);
nexttile(3)
plot_map(region, 'mercator', 'l');
pr = pcolorm(g.lat_rho, g.lon_rho, vari);
uistack(pr, 'bottom')
colormap(jet)
caxis(climit)
title('ROMS', 'FontSize', 20)

plabel('off')

c = colorbar;
c.Title.String = unit;
c.FontSize = 12;

pause(3)

print(['cmp_', vari_str, '_models_', ystr, mstr], '-dpng')