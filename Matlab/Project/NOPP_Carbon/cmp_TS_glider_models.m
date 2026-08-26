clear; clc

domain = 'Oregon_1km_large';
cd(['/data/jungjih/Project/NOAA_NOPP_Carbon/', domain, '/Results/General'])

expname = 'LiveOcean_rad_out';
filepath_ROMS = ['/data/jungjih/Project/NOAA_NOPP_Carbon/', domain, '/Results/Output_', expname, '/'];
filepath_LiveOcean = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_LiveOcean/LiveOcean/';
filepath_WCOFS = '/data/jungjih/Project/NOAA_NOPP_Carbon/Oregon_1km/Results/Output_WCOFS/WCOFS/';

line = 'OR';
vari_str = 'salt';

yyyy = 2024;
ystr = num2str(yyyy);
mm = 2;
mstr = num2str(mm, '%02i');

g = grd(domain);
ismap = 0;

switch vari_str
    case 'temp'
        unit = '^oC';
        climit = [4 20];
        interval1 = 2;
        climit2 = [-3 3];
        interval2 = 0.5;
        title_str = 'Temperature';
        colormap_interval = 16;

    case 'salt'
        unit = 'psu';
        climit = [31 35];
        interval1 = 1;
        climit2 = [-2 2];
        interval2 = .2;
        title_str = 'Salinity';
        colormap_interval = 16;
end
cistr = num2str(colormap_interval);
xlimit = [-126 -124];
ylimit = [-500 0];
FS = 14;

load([filepath_ROMS, 'cmp_data_glider_', domain, '_', expname, '_', line, '_', ystr, mstr, '.mat']);

figure;
set(gcf, 'Position', [1 200 1600 900])
t = tiledlayout(2,4);
t.Padding = 'compact';
t.TileSpacing = 'tight';

% Map
nexttile(5);
plot_map(domain, 'mercator', 'l');
setm(gca,'MLabelLocation',2)
[cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k');
cl = clabelm(cs, h);
set(cl, 'BackgroundColor', 'none');
plotm(lat_line, lon_line, '.r');
mlabel('FontSize', FS)
title('(e) Glider obs line', 'FontSize', FS)
    
vari_obs = eval([vari_str, '_interp']);
vari_ROMS = eval([vari_str, '_ROMS']);

ax1 = nexttile(1); hold on;
pcolor(lon_line, -depth_interp, vari_obs'); shading flat
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
colormap(ax1, ['jet(', cistr, ')'])
caxis(climit);
xlabel('Longitude (^o)')
ylabel('Depth (m)')
set(gca, 'FontSize', FS)
title('(a) Glider')
box on

% ROMS
ax2 = nexttile(2);
pcolor(lon_line, -depth_interp, vari_ROMS'); shading flat
colormap(ax2, ['jet(', cistr, ')'])
caxis(climit);
title('(b) Model')
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on

ax6 = nexttile(6);
vari_diff = vari_ROMS - vari_obs;
pcolor(lon_line, -depth_interp, vari_diff'); shading flat
[color2, contour_interval2] = get_color('redblue', climit2, interval2);
colormap(ax6, color2);
caxis(climit2)
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
ylabel('Depth (m)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on
title('(f) Diff (Model - Glider)')

% LiveOcean
load([filepath_LiveOcean, 'cmp_data_glider__', line, '_', ystr, mstr, '.mat']);
vari_ROMS = eval([vari_str, '_ROMS']);

ax3 = nexttile(3);
pcolor(lon_line, -depth_interp, vari_ROMS'); shading flat
colormap(ax3, ['jet(', cistr, ')'])
caxis(climit);
title('(c) LiveOcean')
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on

ax7 = nexttile(7);
vari_diff = vari_ROMS - vari_obs;
pcolor(lon_line, -depth_interp, vari_diff'); shading flat
[color2, contour_interval2] = get_color('redblue', climit2, interval2);
colormap(ax7, color2);
caxis(climit2)
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on
title('(g) Diff (LiveOcean - Glider)')

% WCOFS
load([filepath_WCOFS, 'cmp_data_glider_WCOFS__', line, '_', ystr, mstr, '.mat']);
vari_ROMS = eval([vari_str, '_ROMS']);

ax4 = nexttile(4);
pcolor(lon_line, -depth_interp, vari_ROMS'); shading flat
colormap(ax4, ['jet(', cistr, ')'])
caxis(climit);
title('(d) WCOFS')
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on

c = colorbar;
c.Title.String = unit;
c.Ticks = climit(1):interval1:climit(end);

ax8 = nexttile(8);
vari_diff = vari_ROMS - vari_obs;
pcolor(lon_line, -depth_interp, vari_diff'); shading flat
[color2, contour_interval2] = get_color('redblue', climit2, interval2);
colormap(ax8, color2);
caxis(climit2)
xlim(xlimit);
ylim(ylimit);
xticks(xlimit(1):xlimit(end))
yticks(ylimit(1):100:ylimit(end)-1)
xlabel('Longitude (^o)')
% yticklabels('');
set(gca, 'FontSize', FS)
box on
title('(h) Diff (WCOFS - Glider)')

c = colorbar;
c.Title.String = unit;

print(['cmp_', vari_str, '_glider_models_', line, '_', ystr, mstr], '-dpng')