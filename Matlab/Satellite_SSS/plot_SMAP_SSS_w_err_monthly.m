%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot SMAP SSS monthly with total formal uncertainty
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Bering';

vari_str = 'salt';
yyyy_all = 2015:2023;
mm_all = 1:12;

climit = [32.5 34.5];
climit_unc = [0 2];
unit = 'g/kg';

lons_sat = {'lon'};
lons_360ind = [360];
lats_sat = {'lat'};
varis_sat = {'sss_smap'};
uncs_sat = {'sss_smap_unc'};
titles_sat = {'RSS SMAP L3 SSS v5.3 8-day MA (70 km)'};

h1 = figure;
set(gcf, 'Position', [1 200 1000 500])
% tiledlayout(1,2);
% Figure title
% ttitle = annotation('textbox', [.30 .85 .60 .15], 'String', titles_sat{1});
% ttitle.FontSize = 20;
% ttitle.EdgeColor = 'None';

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    % Satellite SSS
    % RSS SMAP v5.3 (https://catalog.data.gov/dataset/rss-smap-level-3-sea-surface-salinity-standard-mapped-image-8-day-running-mean-v5-0-valida-ce1a1)
    filepath_RSS_70 = ['/data/jungjih/Observations/Satellite_SSS/Global/RSS/monthly/', ystr, '/'];

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

        % Satellite
        for si = 1:1
            filepath_sat = filepath_RSS_70;
            filepattern1_sat = fullfile(filepath_sat, (['*', ystr, mstr, '*.nc']));
            filepattern2_sat = fullfile(filepath_sat, (['*', ystr, '_', mstr, '*.nc']));

            filename_sat = dir(filepattern1_sat);
            if isempty(filename_sat)
                filename_sat = dir(filepattern2_sat);
            end
            if isempty(filename_sat)
                disp(['missing data in ', ystr, mstr])
                break
            end

            file_sat = [filepath_sat, filename_sat.name];
            lon_sat = double(ncread(file_sat,lons_sat{si}));
            lat_sat = double(ncread(file_sat,lats_sat{si}));
            vari_sat = double(squeeze(ncread(file_sat,varis_sat{si}))');
            unc_sat = double(squeeze(ncread(file_sat,uncs_sat{si}))');

            if si == 3 || si == 4
                index1 = find(lon_sat > 0); index2 = find(lon_sat < 0);
                vari_sat_anomaly = [vari_sat_anomaly(:,index1) vari_sat_anomaly(:,index2)];
            end
            lon_sat = lon_sat - lons_360ind(si);

            % Tile
%             nexttile(1);

            plot_map(map, 'mercator', 'l')
            hold on;

            p1 = pcolorm(lat_sat,lon_sat,vari_sat);
            colormap parula
            caxis(climit)
            c = colorbar;
            c.Title.String = unit;

            % Tile
%             nexttile(2);

%             plot_map(map, 'mercator', 'l')
%             hold on;
            unc_sat(isnan(unc_sat) == 1) = 0;
            [cs,h] = contourm(lat_sat,lon_sat,unc_sat, [0.5 1 1.5 2], 'k');
            cl = clabelm(cs,h);
            for ci = 1:length(cl)
                cl(ci).BackgroundColor = 'none';
            end

            t = title([title_str, ' (Color = SSS, Contour = Uncertatinty with 0.5 interval)']);
            t.FontSize = 12;

%             colormap parula
%             caxis(climit_unc)
%             c = colorbar;
%             c.Title.String = unit;
%             title(['SSS SMAP uncertainty (', title_str, ')'])

            print(strcat('RSS_SMAP_SSS_with_unc_monthly_', ystr, mstr),'-dpng');
            pause(1)

            % Make gif
            gifname = ['RSS_SMAP_SSS_with_unc_monthly.gif'];

            frame = getframe(h1);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            if exist(gifname) == 0
                imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
            else
                imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
            end

            delete(p1); delete(h);

            disp([ystr, mstr, '...'])
        end % si
    end % mi
end % yi