clear; clc; close all

domain = 'Oregon_1km';
map = 'Oregon_1km';
expname = 'bio_hmin_10m_20240501';
cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

yyyy = 2024;
timenums = datenum(yyyy,5,1):datenum(yyyy,5,2);
tinterval = 10/60/24;
time_1D = timenums(1):tinterval:(timenums(end)+1);

layer = 45;
lstr = num2str(layer);

bio = spitz_bio_vars();
num_varis = length(bio);

climits_min = -50*ones(1,num_varis);
climits_max = 50.*ones(1,num_varis);

f1 = figure;
set(gcf, 'Position', [1 200 1800 700])
t = tiledlayout(2,9);
t.Padding = 'compact';
t.TileSpacing = 'compact';

for vi = 1:num_varis
        vari_str = bio(vi).name;

        depth = [];
        vari = [];
        for ti = 1:length(timenums)
            timenum = timenums(ti);
            yyyymmdd = datestr(timenum, 'yyyymmdd');
            filename = ['profile_', yyyymmdd, '.mat'];
            load(filename)
            
            depth_tmp = profile.depth;
            depth = [depth depth_tmp];

            vari_tmp = eval(['profile.', vari_str]);
            vari = [vari vari_tmp];
        end
        time = repmat(time_1D, [size(depth,1),1]);
            
        bi = find(strcmp({bio.name}, vari_str), 1);
        unit = bio(bi).units;

        nexttile(vi); hold on;
        p = pcolor(time, depth, vari); shading flat
        colormap jet
        xticks(timenums)
        datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
        if vi == 1 || vi == 10
            ylabel('Depth (m)')
        end
        set(gca, 'FontSize', 12);

        caxis([climits_min(vi) climits_max(vi)]);
        c = colorbar;
        c.Location = 'SouthOutside';
        c.Label.String = bio_unit_label(unit);
        c.FontSize = 10;
        title(vari_str, 'FontSize', 12)
end

print(['bio_timeseries_layer_', lstr], '-dpng')