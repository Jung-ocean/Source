clear; clc; close all

domain = 'Oregon_1km';
expname = 'bio_20261008';
expname_previous = 'bio_20261008';

cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

iscmpswrad = 0;

filenums = 1:36;

bio = spitz_bio_vars();
num_varis = length(bio);

layer = 45;
lstr = num2str(layer);
region = 'OR_shelf';

if iscmpswrad == 1
    timenum = [];
    swrad = [];
    for fi = 1:length(filenums)
        filenum = filenums(fi);
        fstr = num2str(filenum, '%04i');
        filename = ['vari_', expname, '_', fstr, '.mat'];
        file = filename;
        load(file);

        swrad = [swrad; squeeze(vari_bio.swrad)];
        timenum = [timenum; floor(vari_bio.timenum)];
    end
    data = load_OOI_data_daily(region, 'swrad_net', timenum);

    figure; hold on; grid on;
    set(gcf, 'Position', [1 200 1300 500]);
    po = plot(timenum, data, '-r', 'LineWidth', 2);
    pm = plot(timenum, swrad, '-k', 'LineWidth', 2);
    xticks(datenum(2024,1:12,1));
    xlim([datenum(2024,1,1)-1 datenum(2024,12,31)+1])
    datetick('x', 'mm/dd', 'keepticks', 'keeplimits')
    ylabel('W/m^2')
    set(gca, 'FontSize', 15);
    l = legend([po, pm], 'Observation', 'Model');
    l.Location = 'NorthWest';
    l.FontSize = 15;
    title(['Shortwave radiation (', replace(region, '_', ' '), ')']);
    print('cmp_swrad_OOI', '-dpng')
end

isnew = 1;
[l1, l2] = fun_cmp_bio_variables(expname, filenums, layer, region, 'k', isnew);

isnew = 0;
filenums = 1:36;
fun_cmp_bio_variables(expname_previous, filenums, layer, region, [0.0745 0.6235 1.0000], isnew);

l1.String(3) = {['Model (', replace(expname_previous, '_', ' '), ')']};
l2.String(3) = {['Model (', replace(expname_previous, '_', ' '), ')']};

print(['cmp_bio_variables_OOI_', region, '_layer_', lstr], '-dpng')