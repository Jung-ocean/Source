clear; clc; close all

datenum_start = datenum(2025,7,1);
dsstr = datestr(datenum_start, 'yyyymmdd');
datenum_end = datenum(2025,7,4);
destr = datestr(datenum_end, 'yyyymmdd');

load(['ROMS_BSL_', dsstr, '_', destr, '.mat']);
load(['ROMS_SSSH_', dsstr, '_', destr, '.mat']);

g = grd('NANOOS');

unit = 'cm';
climit = [-1.5 1.5];
interval = [.3];
[color, contour_interval] = get_color('redblue', climit, interval);

f1 = figure; hold on;
set(gcf, 'Position', [1 200 1000 800])
t = tiledlayout(1,2);
t.Padding = 'Compact';
t.TileSpacing = 'None';

for ti = 1:size(BSL_filtered,3)
    title(t, {datestr(timenum(ti), 'mm/dd/yy HH:MM')}, 'FontSize', 20);

    SSSH_tmp = 100*squeeze(SSSH_filtered(:,:,ti)); % m to cm
    BSL_tmp = 100*squeeze(BSL_filtered(:,:,ti)); % m to cm

    nexttile(1);
    if ti == 1
        plot_map('US_west', 'mercator', 'l')
        contourm(lat, lon, g.h, [200 1000], 'k');
    end
    psssh = plot_contourf([], lat, lon, SSSH_tmp, color, climit, contour_interval);
    title(['ROMS M2 SSSH'], 'FontSize', 15)

    nexttile(2);
    if ti == 1
        plot_map('US_west', 'mercator', 'l')
        contourm(lat, lon, g.h, [200 1000], 'k');
        plabel('off')

        c = colorbar;
        c.Title.String = unit;
        c.Ticks = contour_interval;
        c.FontSize = 15;
    end
    pbsl = plot_contourf([], lat, lon, BSL_tmp, color, climit, contour_interval);
    title(['ROMS M2 BSL'], 'FontSize', 15)

    % Make gif
    gifname = ['ROMS_SSSH_and_BSL_', dsstr, '_', destr, '.gif'];
    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(psssh)
    delete(pbsl)
end