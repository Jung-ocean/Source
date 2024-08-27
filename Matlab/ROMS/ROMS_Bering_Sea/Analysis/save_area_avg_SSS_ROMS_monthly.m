%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr';

vari_str = 'salt';
yyyy_all = 2018:2022;
mm_all = 1:12;
layer = 45;

isice = 0;
aice_value = 0.4;

% Load grid information
g = grd('BSf');
[mask, area] = mask_and_area(region, g);

figure; hold on;
set(gcf, 'Position', [1 200 800 500])
plot_map('Bering', 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [50 200], 'k')
pcolorm(g.lat_rho, g.lon_rho, mask);
print('region', '-dpng')

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
case_control = 'Dsm2_spng';
filepath_control = [filepath_all, case_control, '/monthly/'];

SSS_surf = [];
SSS_bot = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
  
    for mi = 1:length(mm_all)
        mm = mm_all(mi); mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filepattern_control = fullfile(filepath_control,(['*',ystr,mstr,'*.nc']));
        filename_control = dir(filepattern_control);
        if ~isempty(filename_control)
            file_control = [filepath_control, filename_control.name];
            vari_surf = ncread(file_control,vari_str,[1 1 layer 1],[Inf Inf 1 1])';
            vari_bot = ncread(file_control,vari_str,[1 1 1 1],[Inf Inf 1 1])';

            if isice == 1
                try
                    aice_mask = ncread(file_control,'aice')';
                    aice_mask(aice_mask >= aice_value) = NaN;
                    aice_mask(aice_mask < aice_value) = 1;
                    mask_with_ice = mask.*aice_mask;
                    area_with_ice = area.*aice_mask;

                    vari_control_shelf(12*(yi-1) + mi) = sum(vari_surf(index_shelf).*area_with_ice(index_shelf), 'omitnan')./sum(area_with_ice(index_shelf), 'omitnan');
                    vari_control_basin(12*(yi-1) + mi) = sum(vari_surf(index_basin).*area_with_ice(index_basin), 'omitnan')./sum(area_with_ice(index_basin), 'omitnan');
                catch
                    vari_control_shelf(12*(yi-1) + mi) = sum(vari_surf(index_shelf).*area(index_shelf), 'omitnan')./sum(area(index_shelf), 'omitnan');
                    vari_control_basin(12*(yi-1) + mi) = sum(vari_surf(index_basin).*area(index_basin), 'omitnan')./sum(area(index_basin), 'omitnan');
                end
            else
                SSS_surf_tmp = sum(vari_surf(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
                SSS_bot_tmp = sum(vari_bot(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');

                SSS_surf = [SSS_surf; SSS_surf_tmp];
                SSS_bot = [SSS_bot; SSS_bot_tmp];
            end % isice

        else
            SSS_surf = [SSS_surf; NaN];
            SSS_bot = [SSS_bot; NaN];
            continue
        end
             
        disp([ystr, mstr, '...'])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS_surf, '-o');
% plot(timenum, SSS_bot, '-o');
xticks(datenum(yyyy_all,1,15));
xlim([datenum(yyyy_all(1),1,1) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

save(['SSS_ROMS_', region, '.mat'], 'timenum', 'SSS_surf', 'SSS_bot')