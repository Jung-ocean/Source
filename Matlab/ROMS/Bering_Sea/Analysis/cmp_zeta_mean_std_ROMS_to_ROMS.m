%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compare ROMS variable to ROMS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

vari_str = 'zeta';
yyyy_all = 2020:2020;
mm_all = 1:4;
layer = 1;
lstr = num2str(layer);
% dd_all = 1:28;
% depth_shelf = 200; % m

datenum_start = datenum(yyyy_all(1), mm_all(1), 1);
datenum_end = datenum(yyyy_all(end), mm_all(end), eomday(yyyy_all(end), mm_all(end)));

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;
h = g.h;
mask = g.mask_rho./g.mask_rho;
startdate = datenum(2018,7,1,0,0,0);
reftime = datenum(1968,5,23,0,0,0);

switch vari_str
    case 'zeta'
        color = 'redblue';
        climit = [-1 1];
        interval = 0.5;
        unit = 'm';

        lat_plot = lat;
        lon_plot = lon;
    case 'svstr'
        color = 'redblue';
        climit = [-1 1];
        interval = 0.5;
        unit = 'N/m^2';

        lat_plot = g.lat_v;
        lon_plot = g.lon_v;
        mask = g.mask_v./g.mask_v;
end

% Model control
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm2_spng/'];
case_con = '';
label_con = 'Control';
filepath_con = [filepath_all, case_con, '/ncks/'];

% Model experiment
case_exp = 'Dsm2_spng_awdrag';
label_exp = 'Wind drag only';
filepath_exp = [filepath_all, case_exp, '/ncks/'];

ti = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            ti = ti+1;
            dd = di; dstr = num2str(dd, '%02i');

            filenum = datenum(yyyy,mm,dd) - startdate + 1;
            fstr = num2str(filenum, '%04i');
            filename = [vari_str, '_', fstr, '.nc'];
            
            % ROMS control
            file = [filepath_con, filename];
            vari_con(:,:,ti) = ncread(file, vari_str);
            ot = ncread(file, 'ocean_time');

            % ROMS exp
            file = [filepath_exp, filename];
            vari_exp(:,:,ti) = ncread(file, vari_str);
            ot = ncread(file, 'ocean_time');

            disp([ystr, mstr, dstr, '...'])
        end % di
    end % mi
end % yi

vari_con_mean = mean(vari_con,3);
vari_con_std = std(vari_con,[],3);

vari_exp_mean = mean(vari_exp,3);
vari_exp_std = std(vari_exp,[],3);

[color_redblue, contour_interval] = get_color('redblue', [-20 20], 5);

% Figure
f1 = figure; hold on;
set(gcf, 'Position', [1 200 1500 800])
t = tiledlayout(2,3);
title(t, {[datestr(datenum_start, 'mmm dd'), ' - ', datestr(datenum_end, 'mmm dd, yyyy')], ''}, 'FontSize', 20)

ax1 = nexttile(1);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*vari_con_mean);
caxis([-80 30])
colormap(ax1, jet(22))
title('Mean (Control)', 'FontSize', 15)

ax2 = nexttile(2);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*vari_exp_mean);
caxis([-80 30])
colormap(ax2, jet(22))
c = colorbar;
c.Title.String = 'cm';
c.FontSize = 12;
plabel off
title('Mean (Wind drag only)', 'FontSize', 15)

ax3 = nexttile(3);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*(vari_exp_mean - vari_con_mean));
caxis([-20 20])
colormap(ax3, color_redblue)
c = colorbar;
c.Title.String = 'cm';
c.FontSize = 12;
plabel off
title('Difference', 'FontSize', 15)

ax4 = nexttile(4);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*vari_con_std);
caxis([0 60]);
colormap(ax4, jet(12))
title('Std. (Control)', 'FontSize', 15)

ax5 = nexttile(5);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*vari_exp_std);
caxis([0 60]);
colormap(ax5, jet(12))
c = colorbar;
c.Title.String = 'cm';
c.FontSize = 12;
plabel off
title('Std. (Wind drag only)', 'FontSize', 15)

ax6 = nexttile(6);
plot_map('Bering', 'mercator', 'l')
plabel('FontSize', 12);
mlabel('FontSize', 12);
contourm(lat, lon, h, [50 100 200], 'k');
pcolorm(lat, lon, 100*(vari_exp_std - vari_con_std));
caxis([-20 20])
colormap(ax6, color_redblue)
c = colorbar;
c.Title.String = 'cm';
c.FontSize = 12;
plabel off
title('Difference', 'FontSize', 15)

print(['cmp_zeta_mean_std_', datestr(datenum_start, 'yyyymmdd'), '_', datestr(datenum_end, 'yyyymmdd')], '-dpng')