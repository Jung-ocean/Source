%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS SSS monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Gulf_of_Anadyr_common';

exp = 'Dsm4';
vari_str = 'salt';
yyyy_all = 2019:2022;
mm_all = 1:12;
layer = 45;

ismap = 0;
isice = 0;
aice_value = 0.4;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load mask_common.mat
    dx = 1./g.pm; dy = 1./g.pn;
    mask = mask_common./mask_common;
    area = dx.*dy.*mask;
else
    [mask, area] = mask_and_area(region, g);
end

if ismap == 1
    % Area plot
    mask_map = mask;
    mask_map(isnan(mask_map) == 1) = 0;
    
    figure; hold on;
    set(gcf, 'Position', [1 200 800 500])
    plot_map('NW_Bering', 'mercator', 'l');
    contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_' region], '-dpng')
end

% Model
filepath_all = ['/data/jungjih/ROMS_BSf/Output/Multi_year/'];
filepath_control = [filepath_all, exp, '/monthly/'];

SSS_surf = [];
SSS_bot = [];
S_volavg = [];
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
            zeta = ncread(file_control,'zeta');
            vari = ncread(file_control,vari_str);
            vari_surf = squeeze(vari(:,:,g.N));
            vari_bot = squeeze(vari(:,:,1));

            if isice == 1
                try
                    aice_mask = ncread(file_control,'aice');
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

              z_w = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.Tcline,g.N,'w',2);
              Hz=z_w(:,:,2:end)-z_w(:,:,1:end-1);

            % volume and volume-ave salt from the time avg fields:
            T = vari;
            mask_ave = mask;
            mask_ave(isnan(mask_ave) == 1) = 0;
            mask3d=repmat(mask_ave,[1 1 g.N]);

            T(mask3d==0)=0; % zero out cells that are not needed, also fills nan spots
            Hz(mask3d==0)=0;

            A3d=repmat(dxdy,[1 1 g.N]);
            TV=sum(T.*Hz.*A3d,'all');
            V=sum(Hz.*A3d,'all');
            Tave=TV/V;

            S_volavg = [S_volavg; Tave];
        else
            SSS_surf = [SSS_surf; NaN];
            SSS_bot = [SSS_bot; NaN];
            S_volavg = [S_volavg; NaN];
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

if length(mm_all) == 1
    output_filename = ['SSS_ROMS_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['SSS_ROMS_', region, '.mat'];
end
save(output_filename, 'timenum', 'SSS_surf', 'SSS_bot', 'S_volavg')