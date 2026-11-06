function [l1, l2] = fun_cmp_bio_variables(expname, filenums, layer, region, color, isnew)

filepath = ['/data/jungjih/Project/NOPP_Carbon/Oregon_1km/Results/Output_', expname, '/'];

bio = spitz_bio_vars();
num_varis = length(bio);

lstr = num2str(layer);

ylimit1 = zeros(num_varis+1,1);
ylimit2 = [...
    30 0.8 10 ...
    0.8 1 1.7 ...
    1.5 3 5 ...
    60 3 25 ...
    10 0.1 0.6 ...
    0.05 20 20 ...
    ];

% Bio variables
timenum = [];
for vi = 1:num_varis
    vari_str = bio(vi).name;
    eval([vari_str, ' = [];'])
end

for fi = 1:length(filenums)
    filenum = filenums(fi);
    fstr = num2str(filenum, '%04i');
    filename = ['vari_', expname, '_', fstr, '.mat'];
    file = [filepath, filename];
    load(file);

    for vi = 1:num_varis
        vari_str = bio(vi).name;
        eval([vari_str, ' = [', vari_str, ' vari_bio.', vari_str, '(', lstr, ',:)];'])
    end
    timenum = [timenum; floor(vari_bio.timenum)];
end

if isnew == 1
    f1 = figure;
    set(gcf, 'Position', [1 200 1800 800])
    t = tiledlayout(6,3);
    t.Padding = 'compact';
    t.TileSpacing = 'compact';
end

for vi = 1:num_varis
    nexttile(vi); hold on; grid on;
    vari_str = bio(vi).name;
    vari = eval(vari_str);

    bi = find(strcmp({bio.name}, vari_str), 1);
    unit = bio(bi).units;

    pm = plot(timenum, vari, '-', 'Color', color);
    xticks(datenum(2024,1:12,1));
    xlim([datenum(2024,1,1)-1 datenum(2024,12,31)+1])
    ylim([ylimit1(vi) ylimit2(vi)]);
    datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
    ylabel(bio_unit_label(unit));
    set(gca, 'FontSize', 8)

    if isnew == 1
        timenum_obs = datenum(2024,1,1):datenum(2024,12,31);
        if strcmp(vari_str, 'NO3')
            data = load_OOI_data_daily(region, 'NO3', timenum_obs);
            po = plot(timenum_obs, data, '-r');
            l1 = legend([po, pm], ['Obs (', replace(region, '_', ' '), ')'], 'Model');
            l1.Location = 'NorthWest';
        end
    end

    title(vari_str)
end

nexttile(18); hold on; grid on;
vari1_str = 'Chlorophyll';
vari1 = eval(vari1_str);
vari2_str = 'ChlD';
vari2 = eval(vari2_str);
vari = vari1+vari2;

bi = find(strcmp({bio.name}, vari1_str), 1);
unit = bio(bi).units;

pm = plot(timenum, vari, '-', 'Color', color);
xticks(datenum(2024,1:12,1));
xlim([datenum(2024,1,1)-1 datenum(2024,12,31)+1])
ylim([ylimit1(end) ylimit2(end)]);
datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
ylabel(bio_unit_label(unit));
set(gca, 'FontSize', 8)

if isnew == 1
    timenum_obs = datenum(2024,1,1):datenum(2024,12,31);
    data = load_OOI_data_daily(region, 'Chla', timenum_obs);
    po = plot(timenum_obs, data, '-r');
    l2 = legend([po, pm], 'Obs (Chla)', 'Model (Chlorophyll + ChlD)');
    l2.Location = 'NorthWest';
end

title('Chlorophyll comparison')

end