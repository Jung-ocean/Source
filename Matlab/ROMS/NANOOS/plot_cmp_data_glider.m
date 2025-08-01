clear; clc; close all

yyyy = 2024;
ystr = num2str(yyyy);
mm = 2;
mstr = num2str(mm, '%02i');

vari_str = 'pden';

gn = grd('NANOOS');
ismap = 0;
isdiff = 1;

switch vari_str
    case 'temp'
        unit = '^oC';
        climit = [4 15];
        climit2 = [-3 3];
        title_str = 'Temperature';

    case 'salt'
        unit = 'psu';
        climit = [32 35];
        climit2 = [-2 2];
        title_str = 'Salinity';

    case 'pden'
        unit = '\sigma_\theta';
        climit = [22 27];
        climit2 = [-1.5 1.5];
        title_str = 'Potential density';
end
xlimit = [-126 -124];
ylimit = [-500 0];

load(['cmp_data_glider_', ystr, mstr, '.mat']);

if ismap == 1
    % Map
    figure;
    set(gcf, 'Position', [1 200 500 800])
    plot_map('US_west', 'mercator', 'l');
    [cs, h] = contourm(gn.lat_rho, gn.lon_rho, gn.h, [100 200 1000 2000], 'k');
    cl = clabelm(cs, h);
    set(cl, 'BackgroundColor', 'none');
    plotm(lat_line, lon_line, '.r');
    print(['map_cmp_data_glider_', ystr, mstr], '-dpng')
end

vari_obs = eval([vari_str, '_interp']);
vari_NANOOS = eval([vari_str, '_NANOOS']);
vari_WCOFS = eval([vari_str, '_WCOFS']);
if strcmp(vari_str, 'pden')
    vari_obs = pden_interp - 1000;
    vari_NANOOS = vari_NANOOS - 1000;
    vari_WCOFS = vari_WCOFS - 1000;
end

% Comparison
figure;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';
title(t, [title_str, ' (', datestr(min(datenum_line), 'mmm dd'), ' - ', datestr(max(datenum_line), 'dd, yyyy'), ')'], 'FontSize', 15)

ax1 = nexttile(1); hold on;
pcolor(lon_line, -depth_interp, vari_obs'); shading flat
xlim(xlimit);
ylim(ylimit);
colormap(ax1, 'jet(32)')
caxis(climit);
xlabel('Longitude (^o)')
ylabel('Depth (m)')
set(gca, 'FontSize', 15)
title('Glider')
if isdiff == 1
    c = colorbar;
    c.Title.String = unit;
else

end
box on

ax2 = nexttile(2);
if isdiff == 1
    vari_diff_NANOOS = vari_NANOOS - vari_obs;
    pcolor(lon_line, -depth_interp, vari_diff_NANOOS'); shading flat
    colormap(ax2, 'redblue2');
    caxis(climit2)
else
    pcolor(lon_line, -depth_interp, vari_NANOOS'); shading flat
    colormap(ax2, 'jet(32)')
    caxis(climit);
end
xlim(xlimit);
ylim(ylimit);
xlabel('Longitude (^o)')
yticklabels('');
set(gca, 'FontSize', 15)
title('OSU ROMS')
box on

ax3 = nexttile(3);
if isdiff == 1
    vari_diff_WCOFS = vari_WCOFS - vari_obs;
    pcolor(lon_line, -depth_interp, vari_diff_WCOFS'); shading flat
    colormap(ax3, 'redblue2');
    caxis(climit2)
    c = colorbar;
    c.Title.String = unit;
else
    pcolor(lon_line, -depth_interp, vari_WCOFS'); shading flat
    colormap(ax3, 'jet(32)')
    caxis(climit);
    c = colorbar;
    c.Title.String = unit;
end
xlim(xlimit);
ylim(ylimit);
xlabel('Longitude (^o)')
yticklabels('');
set(gca, 'FontSize', 15)
title('WCOFS')
box on

print(['cmp_', vari_str, '_glider_', ystr, mstr], '-dpng')