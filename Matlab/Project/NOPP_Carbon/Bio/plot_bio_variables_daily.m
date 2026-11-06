clear; clc; close all

domain = 'Oregon_1km';
map = 'Oregon_1km';
expname = 'bio_20261008';
cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

yyyy = 2024;
timenums = datenum(yyyy,1,1):datenum(yyyy,12,31);

filepath = ['/data/jungjih/Project/NOPP_Carbon/', domain, '/Outputs/Output_', expname, '/'];
layer = 45;
lstr = num2str(layer);

g = grd(domain);

bio = spitz_bio_vars();
num_varis = length(bio);

isnegative = 0;

if isnegative == 1
    climits_min = -(1e-5)*ones(1,num_varis);
    climits_max = 0.*ones(1,num_varis);
else
    climits_min = 0.*ones(1,num_varis);
    climits_max = [...
        50 0.5 10 0.5 0.5 3 0.5 10 4 ...
        20 5 50 5 0.2 0.4 0.2 10];
end

f1 = figure;
set(gcf, 'Position', [1 200 1800 700])
t = tiledlayout(2,9);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for ti = 1:length(timenums)
    timenum = timenums(ti);
    title(t, {datestr(timenum, 'yyyy-mm-dd'), ''}, 'FontSize', 15)

    tindex = timenum - datenum(yyyy,1,1) + 1;
    
    for vi = 1:num_varis
        vari_str = bio(vi).name;
        filename = [vari_str, '_layer_', lstr, '.nc'];
        file = [filepath, filename];

        bi = find(strcmp({bio.name}, vari_str), 1);
        unit = bio(bi).units;

        vari = ncread(file, vari_str, [1 1 1 tindex], [Inf Inf Inf 1]);
        if isnegative == 1
            vari(vari>0) = NaN;
        end

        nexttile(vi);
        if ti == 1
            plot_map(map, 'mercator', 'l');
            contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
        end

        p(vi) = pcolorm(g.lat_rho, g.lon_rho, vari.*g.mask_rho./g.mask_rho);
        uistack(p(vi), 'bottom');

        if ti == 1
            colormap jet
            caxis([climits_min(vi) climits_max(vi)]);
            c = colorbar;
            c.Label.String = bio_unit_label(unit);
            c.FontSize = 10;
            title(vari_str, 'FontSize', 12)
            setm(gca,'MLabelLocation', 2)

            if vi ~= 1 & vi ~= 10
                plabel('off')
            end
            if vi < 10
                mlabel('off')
            end
        end
        
    end

    % Make gif
    if isnegative == 1
        gifname = ['bio_layer_', num2str(layer), '_', expname, '_', map, '_negative.gif'];
    else
        gifname = ['bio_layer_', num2str(layer), '_', expname, '_', map, '.gif'];
    end

    frame = getframe(f1);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if ti == 1
        imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
    else
        imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
    end

    delete(p)
end