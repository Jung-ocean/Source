clear; clc; close all

mm_all = [1 2 3 4 10 11 12];
yyyy_all = 2010:2025;

filepath = '/data/jungjih/Observations/Sea_ice/SIT/AWI/monthly/';

vari_str = 'SIC';
switch vari_str
    case 'SIT'
        climit = [0 4.5];
        clabel = 'Sea ice thickness [m]';
        color = 'jet(9)';
    case 'SIC'
        climit = [0 100];
        clabel = 'Sea ice concentration [%]';
        color = 'jet(10)';
end

for mi = 1:length(mm_all)
    mm = mm_all(mi);
    mstr = num2str(mm, '%02i');

    figure('Color', 'w');
    t = tiledlayout(4,4);
    t.Padding = 'compact';
    t.TileSpacing = 'compact';

    for yi = 1:length(yyyy_all)
        yyyy = yyyy_all(yi);
        ystr = num2str(yyyy);

        filename = [vari_str, '_', ystr, '_', mstr, '.mat'];
        file = [filepath, filename];
        try
            load(file)
        catch
            continue
        end
        vari = eval(vari_str);

        nexttile(yi);
        plot_arctic_map
        caxis(climit);

        p(yi) = pcolorm(lat, lon, vari);
        uistack(p(yi), 'bottom')
        colormap(color)

        title([ystr, ' ', mstr], 'FontSize', 20)
    end

    c = colorbar;
    c.Layout.Tile = 'east';
    c.Label.String = clabel;
    c.FontSize = 12;

    set(gcf, 'Position', [1 200 1000 900])
    pause(3)

    print([vari_str, '_monthly_', mstr], '-dpng')
end