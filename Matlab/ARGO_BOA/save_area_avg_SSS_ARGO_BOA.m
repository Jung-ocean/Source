%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save area-averaged SSS of ARGO BOA
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

yyyy_all = 2015:2023;
mm_all = [1:12];

region = 'Cape_Olyutor';
area_frac_cutoff = 0.99;

ismap = 1;

[lon_lim, lat_lim] = load_domain('Bering');

% ARGO
filepath_ARGO = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];
mm_all = 1:12;
mstr = num2str(mm_all, '%02i');

% Load grid information
g = grd('BSf');
lon = g.lon_rho;
lat = g.lat_rho;

if strcmp(region, 'Gulf_of_Anadyr_common') | strcmp(region, 'Koryak_coast_common')
    load(['mask_' , maskname, '.mat'])
    %     load(['mask_common_06_15.mat'])
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

SSS = [];
% err = [];
timenum = [];
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);
    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');
        timenum = [timenum; datenum(yyyy,mm,15)];

        filename_ARGO = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file_ARGO = [filepath_ARGO, filename_ARGO];
        if exist(file_ARGO)
            ARGO = load(file_ARGO);
            lon_tmp = ARGO.lon-360;
            lat_tmp = ARGO.lat;
            SSS_tmp = ARGO.salt(:,:,1);

            lonind = find(lon_tmp(:,1) > min(lon_lim)-1 & lon_tmp(:,1) < max(lon_lim) +1);
            latind = find(lat_tmp(1,:) > min(lat_lim)-1 & lat_tmp(1,:) < max(lat_lim) +1);

            lon_tmp2 = lon_tmp(lonind, latind);
            lat_tmp2 = lat_tmp(lonind, latind);
            SSS_tmp2 = SSS_tmp(lonind, latind);

            if ~exist('F', 'var')
                F = scatteredInterpolant(lon_tmp2(:), lat_tmp2(:), 0.*lon_tmp2(:));
            end
            F.Values = SSS_tmp2(:);
            SSS_interp = F(g.lon_rho, g.lat_rho).*mask;
            SSS_tmp3 = sum(SSS_interp(:).*area(:), 'omitnan')./sum(area(:), 'omitnan');
            SSS = [SSS; SSS_tmp3];
            %         err = [err; err_tmp];
        else
            SSS = [SSS; NaN];
        end

        disp([ystr, mstr])
    end % mi
end % yi

figure; hold on; grid on
plot(timenum, SSS, '-o');
xticks(datenum(yyyy_all,1,15));
datetick('x', 'yyyy', 'keepticks', 'keeplimits')

if length(mm_all) == 1
    output_filename = ['SSS_ARGO_BOA_', region, '_', num2str(mm_all, '%02i'), '.mat'];
else
    output_filename = ['SSS_ARGO_BOA_', region, '.mat'];
end

save(output_filename, 'timenum', 'SSS', 'area_frac_cutoff')