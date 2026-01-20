%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS aice daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast_basin';
ismap = 0;

exp = 'Dsm4_mk2';
vari_str = 'aice';
yyyy_all = 2018:2023;
mm_all = 1:12;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;
[mask, area] = mask_and_area(region, g);

if ismap == 1
    % Area plot
    mask_map = mask;
    mask_map(isnan(mask_map) == 1) = 0;

    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('NW_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_', region], '-dpng')
end

aice = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');
            
            datenum_target = datenum(yyyy,mm,dd);
            timenum = [timenum; datenum_target];

            vari = load_BSf_2d_daily(exp, 'aice', datenum_target);
            if isscalar(vari) == 1 | isempty(vari) == 1
                aice = [aice; NaN];
            else
                aice_tmp = sum(vari(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
                aice = [aice; aice_tmp];
            end

            disp([ystr, mstr, dstr, '...'])
        end % di
    end % mi
end % yi

output_filename = ['aice_ROMS_', region, '_daily.mat'];

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 500])
plot(timenum, aice, '-k', 'LineWidth', 2);
xticks([datenum(yyyy_all,1,1)]);
xlim([datenum(yyyy_all(1),1,0) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
set(gca, 'FontSize', 15)

box on
save(output_filename, 'timenum', 'aice')