clear; clc; close all

domain = 'Oregon_1km';
map = 'Oregon_1km_north';
[lon_lim, lat_lim] = load_domain(map);
cd(['/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Results/General_bio/'])

filepath_all = '/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Outputs/';

g = grd(domain);
vari_str = 'NO3';
layer = 1;
lstr = num2str(layer);
filenums = 122:126;

expnames = { ...
    'bio_hmin_10m_20240501_no_RUN_SPITZ', ...
    'bio_hmin_10m_20240501_no_RUN_SPITZ_DT_20', ...
    'bio_hmin_10m_20240501_no_RUN_SPITZ_TNU2_5', ...
    };

bio = spitz_bio_vars();
bi = find(strcmp({bio.name}, vari_str), 1);
unit = bio(bi).units;

figure; hold on;
set(gcf, 'Position', [1 200 1300 500])
t = tiledlayout(1,3);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for fi = 1:length(filenums)
    filenum = filenums(fi);
    fstr = num2str(filenum, '%04i');
    timenum = datenum(2024,1,0) + filenum;
    title(t, [vari_str, ' layer ', lstr, ' (', datestr(timenum, 'mm/dd/yyyy'), ')'], 'FontSize', 25)

    for ei = 1:length(expnames)
        expname = expnames{ei};
        filepath = [filepath_all, 'Output_', expname, '/'];
        filename = ['ocean_his_', fstr, '.nc'];
        file = [filepath, filename];
        vari = ncread(file, vari_str, [1 1 layer 1], [Inf Inf 1 Inf]);
%         vari(vari<0) = NaN;
        
        nexttile(ei); hold on; grid on;
%         if fi == 1
%             plot_map(map, 'mercator', 'l');
%             [cs, h] = contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');
%         end
        p(ei) = pcolor(g.lon_rho, g.lat_rho, vari.*g.mask_rho./g.mask_rho); shading flat
        colormap jet
        xlim(lon_lim);
        ylim(lat_lim);
        uistack(p(ei), 'bottom')
        caxis([-100 100]);
        title(replace(expname(23:end), '_', ' '), 'FontSize', 12)
        if ei ~= 1
            %plabel off
            yticklabels('')
        end
        if ei == 3
            c = colorbar;
            c.FontSize = 12;
            c.Label.String = bio_unit_label(unit);
        end
    end
    if fi == 1
        pause(3)
    end
    print(['cmp_bio_models_his_', vari_str, '_layer_', lstr, '_', datestr(timenum, 'yyyymmdd')], '-dpng')
    delete(p)
end