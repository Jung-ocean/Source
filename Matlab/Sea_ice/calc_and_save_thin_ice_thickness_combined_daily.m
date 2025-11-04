%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate and save thin ice thickness using SMOS-SMAP combined data daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2016:2022;
mm_all = 1:12;

region = 'Koryak_coast_basin';
ismap = 0;

filepath_all = '/data/smithj28/Obersvations/Thin_ice/';

[g, tmp] = load_CICE_daily('hi', datenum(2019,1,1));
[mask, area] = mask_and_area(region, g);

if ismap == 1
    mask(isnan(mask)) = 0;
    % Area plot
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['area_' region], '-dpng')
end

hi = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);

    filepath_daily = [filepath_all, ystr, '/'];
    filename_sat = [num2str(yyyy-1), '_', ystr, '_combined_thickness.mat'];
    file_sat = [filepath_daily, filename_sat];
    data_sat = load(file_sat);

    timenum_sat = datenum(data_sat.thin_ice_data.dates);
    lon_sat = g.lon_rho;
    lat_sat = g.lat_rho;
    mask_sat = g.mask_rho;

    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');

        for di = 1:eomday(yyyy,mm)
            dd = di; dstr = num2str(dd, '%02i');

            timenum_tmp = datenum(yyyy,mm,dd);
            timenum = [timenum; timenum_tmp];

            index = find(timenum_sat == timenum_tmp);
            if isempty(index)
                hi = [hi; NaN];
                continue
            end
            
            vari_sat = data_sat.thin_ice_data.thickness.rect_lon_lat(:,:,index);
            vari_sat(vari_sat > 50) = 50;

            hi_tmp = sum(vari_sat(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
            hi = [hi; hi_tmp];

            disp([ystr, mstr, dstr])
        end % di
    end % mi
end % yi

output_filename = ['hi_thin_combined_', region, '_daily.mat'];

figure; hold on; grid on;
plot(timenum, hi, '-k')
xticks(datenum(yyyy_all,1,1));
datetick('x', 'mm/dd/yy', 'keepticks', 'keeplimits')

ddd
save(output_filename, 'timenum', 'hi')