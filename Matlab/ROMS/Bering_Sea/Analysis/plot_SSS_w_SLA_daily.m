%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS SSSA and zeta anoamly daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'NW_Bering';

exp = 'Dsm4_mk2';
vari_str = 'salt';
yyyy = 2022;
ystr = num2str(yyyy);
mm_all = 1:12;

% Load grid information
g = grd('BSf');

if strcmp(exp, 'Dsm4')
    filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
else
    filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/Dsm4/', exp, '/ncks_daily/'];
end
filename_zeta_climate = 'zeta_climate.nc';
file_zeta_climate = [filepath, filename_zeta_climate];
zeta_climate = ncread(file_zeta_climate, 'zeta');

% Figure properties
climit = [29 34];
interval = 0.25;
[color, contour_interval] = get_color('jet', climit, interval);

unit = 'psu';
savename = 'SSS_and_zetaA';

f1 = figure;
set(gcf, 'Position', [1 200 800 500])
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'Color', [.5 .5 .5]);

for mi = 1:length(mm_all)
    mm = mm_all(mi);

    for di = 1:eomday(yyyy,mm)
        dd = di;
        timenum_tmp = datenum(yyyy,mm,dd);
        filenum = timenum_tmp - datenum(2018,7,1) + 1;
        fstr = num2str(filenum, '%04i');
    
        title_str = datestr(timenum_tmp, 'mmm dd, yyyy');
        title(['SSS (color) and SLA (contour, 10 cm) (', title_str, ')'], 'FontSize', 12)
        
        % SSS
        filename_SSS = ['SSS_', fstr, '.nc'];
        file_SSS = [filepath, filename_SSS];
        SSS = ncread(file_SSS, 'salt');
        ps = plot_contourf([], g.lat_rho, g.lon_rho, SSS, color, climit, contour_interval);
        if di == 1 & mi == 1
            c = colorbar;
            c.Title.String = unit;
        end

        % zetaA
        filename_zeta = ['zeta_', fstr, '.nc'];
        file_zeta = [filepath, filename_zeta];
        zeta = ncread(file_zeta, 'zeta');
        zetaA = zeta - zeta_climate;
        zetaA(isnan(zetaA) == 1) = -9999; % for plotting purpose
        [pz,ph] = contourm(g.lat_rho, g.lon_rho, zetaA, [-3:0.1:3], 'k', 'LineWidth', 1);

        % Make gif
        gifname = ['SSS_w_SLA_', ystr, '_daily', '.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if di == 1 & mi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end

        delete(ps)
        delete(ph)
    end
end