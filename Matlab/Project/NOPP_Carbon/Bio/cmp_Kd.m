clear; clc; close all

domain = 'Oregon_1km';
expname = 'bio_20261008';

cd(['/data/jungjih/Project/NOPP_Carbon/', domain, '/Results/Output_', expname])

regions = {'inshore', 'shelf', 'offshore'};
depths = [25, 80, 588];
filenums = 1:36;

AttSW = 0.04;
KdPAR = AttSW;
AttPhyt = 0.02;
AttPhytDia = 0.02;
BioParFrac = 0.43;

figure;
t = tiledlayout(3,1);
t.Padding = 'compact';
t.TileSpacing = 'compact';
set(gcf, 'Position', [1 200 1300 800]);

for ri = 1:length(regions)
    region = regions{ri};

    timenum = [];
    Kd = [];
    for fi = 1:length(filenums)
        filenum = filenums(fi);
        fstr = num2str(filenum, '%04i');
        filename = ['vari_', expname, '_', fstr, '.mat'];
        file = filename;
        load(file);
        vari = eval(['vari_', region]);

        depth = vari.depth;
        swrad = squeeze(vari.swrad);
        chlor = vari.Chlorophyll;
        chld = vari.ChlD;

        PARsur = BioParFrac.*swrad;

        for i = 1:size(chlor,2)
            z_r = depth(:,i);
            parz = PARsur(i).*exp(z_r.*(KdPAR+(AttPhyt.*chlor(:,i))+AttPhytDia.*chld(:,i)));

            I0 = parz(end);
            I_bottom = parz(1);
            H = z_r(1);

            if I_bottom < 0.01*I0
                z_eu = interp1(parz, z_r, 0.01*I0);
                k_tmp = log(0.01)/z_eu;
            else
                k_tmp = log(I_bottom/I0)/H;
            end

            Kd = [Kd; k_tmp];
        end

        timenum = [timenum; vari.timenum];
    end

    [timenum_obs, Kd_obs] = load_OOI_Kd(['OR_', region], datenum(2024,1,1):datenum(2024,12,31));

    nexttile(ri); hold on; grid on;
    po = plot(timenum_obs, Kd_obs, '.r');
    pm = plot(timenum, Kd, '-k', 'LineWidth', 2);

    xlim([datenum(2024,1,1)-1 datenum(2024,12,31)+1]);
    ylim([0 0.6]);
    xticks(datenum(2024,1:12,1));
    yticks(0:0.1:0.6)
    datetick('x', 'mm/dd');
    xlabel('Date')
    ylabel('Kd');
    set(gca, 'FontSize', 15)

    title(['Oregon ', region, ' (', num2str(depths(ri)), ' m)']);

    if ri == 1
        l = legend([po, pm], 'Obs (OOI)', ['Model (', replace(expname, '_', ' '), ')']);
        l.FontSize = 15;
        l.Location = 'NorthWest';
    end

end

print(['cmp_Kd_', expname], '-dpng')