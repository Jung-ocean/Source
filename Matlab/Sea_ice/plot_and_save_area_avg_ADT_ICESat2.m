%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area averaged ADT from ICESat2 daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;

yyyy = 2021;
mm_all = 1:6;
isfig = 0;
region = 'Gulf_of_Anadyr';

filepath = '/data/jungjih/Observations/Sea_ice/ICESat2/SSHA/data/';

if strcmp(region, 'Gulf_of_Anadyr')
    polygon = [;
        -180.9180   62.3790
        -172.9734   64.3531
        -178.7092   66.7637
        -184.1599   64.8934
        -180.9180   62.3790
        ];

    polygon2 = polygon;
    polygon2(:,1) = polygon2(:,1) + 360;

elseif strcmp(region, 'Norton_Sound')
    polygon = [;
        -166.3047   64.6603
        -164.0475   62.6674
        -160.0348   63.6554
        -160.7155   65.0351
        -166.3047   64.6603
        ];
end

figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
plotm(polygon(:,2), polygon(:,1), '-r', 'LineWidth', 2)
print(['map_', region], '-dpng')
close all

ystr = num2str(yyyy);
ADT_ICESat2 = [];

h1 = figure; hold on; grid on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l');
for mi = 1:length(mm_all)
    mm = mm_all(mi); mstr = num2str(mm, '%02i');

    filename = dir([filepath, 'ATL21-01_', ystr, mstr, '*']);
    filename = filename.name;
    file = [filepath, filename];

    lat = h5read(file, '/grid_lat');
    lon = h5read(file, '/grid_lon');

    [in, on] = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
    mask_target = in./in;
    if strcmp(region, 'Gulf_of_Anadyr')
        [in, on] = inpolygon(lon, lat, polygon2(:,1), polygon2(:,2));
        mask_target2 = in./in;
    end


    for di = 1:eomday(yyyy,mm)
        dd = di; dstr = num2str(dd, '%02i');

        try
            ssha = h5read(file, ['/daily/day', dstr, '/mean_ssha']);
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_ssha/'], '_FillValue');
            ssha(ssha == fv) = NaN;
            mss = h5read(file, ['/daily/day', dstr, '/mean_weighted_mss']);
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_mss/'], '_FillValue');
            mss(mss == fv) = NaN;
            geoid = h5read(file, ['/daily/day', dstr, '/mean_weighted_geoid']);
            fv = h5readatt(file, ['/daily/day', dstr, '/mean_weighted_geoid/'], '_FillValue');
            geoid(geoid == fv) = NaN;
        catch
            ssha = NaN;
            mss = NaN;
            geoid = NaN;
        end

        ADT = mss + ssha - geoid;
        
        if strcmp(region, 'Gulf_of_Anadyr')
            ADT1 = ADT.*mask_target;
            ADT1_val = ADT1(isnan(ADT1) == 0);
            ADT2 = ADT.*mask_target2;
            ADT2_val = ADT2(isnan(ADT2) == 0);
            ADT_val = [ADT1_val; ADT2_val];
        else
            ADT1 = ADT.*mask_target;
            ADT1_val = ADT1(isnan(ADT1) == 0);
            ADT_val = [ADT1_val];
        end
        ADT_ICESat2 = [ADT_ICESat2; mean(ADT_val)];

        if isfig == 1
            p = pcolorm(lat, lon, mss-geoid);
            colormap redblue
            caxis([-1 1])
            c = colorbar;
            c.Title.String = 'm';

            title(datestr(datenum(yyyy,mm,dd), 'mmm dd, yyyy'))
            print(['ADT_ICESat2_daily_', ystr, mstr, dstr], '-dpng')

            % Make gif
            gifname = ['ADT_ICESat2_daily_', ystr, '.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if mi == 1 && di == 1
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end
            delete(p)
        end

    end
end

save(['ADT_ICESat2_', region, '_', ystr, '.mat'], 'ADT_ICESat2')