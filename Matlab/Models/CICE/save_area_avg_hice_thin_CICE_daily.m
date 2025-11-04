%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged CICE thin ice thickness daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast';
ismap = 0;

vari_str = 'hi';
yyyy_all = 2018:2023;
mm_all = 1:12;

[g, tmp] = load_CICE_daily(vari_str, datenum(2019,1,1));

[mask, area] = mask_and_area(region, g);

if ismap == 1
    mask(isnan(mask)) = 0;
    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Bering', 'mercator', 'l');
    lat_tmp = g.lat_rho;
    lon_tmp = g.lon_rho;
    lat_tmp(isnan(lat_tmp)) = 0;
    lon_tmp(isnan(lon_tmp)) = 0;
    contourm(lat_tmp, lon_tmp, g.h, [50 100 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['area_' region, '_CICE'], '-dpng')
end

% Model
filepath_all = ['/data/smithj28/CICE_output/Data/4km_data/seasons/'];

hice = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');
            timenum = [timenum; datenum(yyyy,mm,dd)];
            yyyymmdd = datestr(timenum(end), 'yyyy-mm-dd');

            if mm < 11
                filepath_control = [filepath_all, num2str(yyyy-1), '_', ystr, '/'];
            else
                filepath_control = [filepath_all, ystr, '_', num2str(yyyy+1), '/'];
            end

            filepattern_control = fullfile(filepath_control,(['*',yyyymmdd,'*.nc']));
            filename_control = dir(filepattern_control);
            if ~isempty(filename_control)
                file_control = [filepath_control, filename_control.name];

                vari = ncread(file_control,vari_str);
                vari = vari.*100; % m to cm
                vari(vari > 50) = 50;
                if isempty(vari) == 1
                    hice = [hice; NaN];
                else
                    hice_tmp = sum(vari(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
                    hice = [hice; hice_tmp];
                end
            else
                hice = [hice; NaN];
            end

            disp([ystr, mstr, dstr, '...'])
        end % di
    end % mi
end % yi

output_filename = ['hice_thin_CICE_', region, '_daily.mat'];

figure; hold on; grid on
set(gcf, 'Position', [1 200 1300 500])
plot(timenum, hice, '-k', 'LineWidth', 2);
xticks([datenum(yyyy_all,1,1)]);
xlim([datenum(yyyy_all(1),1,0) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')
set(gca, 'FontSize', 15)

box on
save(output_filename, 'timenum', 'hice')