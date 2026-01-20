%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged ROMS SSS daily
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'Koryak_coast';
% maskname = ['common_07_01'];

exp = 'Dsm4_mk2';
startdate = datenum(2018,7,1);
vari_str = 'salt';
yyyy_all = 2018:2023;
mm_all = 1:12;
layer = 45;

ismap = 0;

% Load grid information
g = grd('BSf');
dx=1./g.pm;
dy=1./g.pn;
dxdy = dx.*dy;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load(['mask_', maskname, '.mat'])
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
    contourm(g.lat_rho, g.lon_rho, g.h, [200 200], 'k')
    [c,h] = contourfm(g.lat_rho, g.lon_rho, mask_map, [1 1], '--r', 'LineWidth', 2);
    set(h.Children(2), 'FaceColor', 'r')
    set(h.Children(2), 'FaceAlpha', 0.2)
    set(h.Children(3), 'FaceColor', 'none')
    print(['region_' region], '-dpng')
end

timenum = [datenum(yyyy_all(1), mm_all(1),1):datenum(yyyy_all(end), mm_all(end), eomday(yyyy_all(end), mm_all(end)))]';
SSS = NaN(length(timenum),1);
S_bot = NaN(length(timenum),1);
S_volavg = NaN(length(timenum),1);
dataind = 0;
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        for di = 1:eomday(yyyy,mm)
            dataind = dataind+1;
            dd = di;
            timenum_tmp = datenum(yyyy,mm,dd);

            zeta = load_BSf_daily(exp, 'zeta', timenum_tmp);
            vari = load_BSf_daily(exp, vari_str, timenum_tmp);
            if ~isscalar(vari) & ~isempty(vari)
                vari_surf = vari(:,:,g.N);
                vari_bot = vari(:,:,1);

                SSS_surf_tmp = sum(vari_surf(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
                SSS_bot_tmp = sum(vari_bot(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');

                SSS(dataind) = SSS_surf_tmp;
                S_bot(dataind) = SSS_bot_tmp;

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

                S_volavg(dataind) = Tave;
            end

            disp([datestr(timenum_tmp, 'yyyymmdd'), '...'])
        end
    end
end

figure; hold on; grid on
plot(timenum, SSS, '-');
plot(timenum, S_volavg, '-');
xticks(datenum(yyyy_all,1,1));
xlim([datenum(yyyy_all(1),1,1) datenum(yyyy_all(end)+1,1,1)])
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

output_filename = ['salt_ROMS_', region, '_daily.mat'];

save(output_filename, 'timenum', 'SSS', 'S_bot', 'S_volavg')