%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Save common area between SMAP and SMOS
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; %close all

yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

isdaily = 1;
if isdaily == 1
    dd = 1;
    dstr = num2str(dd, '%02i');
end

depth_cutoff = 0;

g = grd('BSf');

% % Gulf of Anadyr
polygon = [;
    -180.9180   62.3790
    -172.9734   64.3531
    -178.7092   66.7637
    -184.1599   64.8934
    -180.9180   62.3790
    ];

% Koreak_coast
% polygon = [;
%     -189.6556   59.6227
%     -180.5050   61.0029
%     -181.5623   62.2387
%     -190.6764   61.2276
%     -189.6556   59.6227
%     ];

[in, on] = inpolygon(g.lon_rho, g.lat_rho, polygon(:,1), polygon(:,2));
mask = double(in);

mask_common = ones(size(g.mask_rho));
for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    mstr = num2str(mm, '%02i');

    % SMAP
    if isdaily == 1
        [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_daily('SMAP', 6, datenum(yyyy, mm, dd));
    else
        [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMAP', 6, yyyy, mm);
    end
    if ~isscalar(vari_sat)
        if ~exist('Fsmap')
            [lat_sat2, lon_sat2] = meshgrid(lat_sat, lon_sat);
            Fsmap = griddedInterpolant(lat_sat2', lon_sat2', 0.*lat_sat2');
        end
        Fsmap.Values = vari_sat';

        %vari_sat_interp = griddata(lat_sat, lon_sat, vari_sat, g.lat_rho, g.lon_rho);
        vari_sat_interp = Fsmap(g.lat_rho, g.lon_rho);
        mask_sat = double(~isnan(vari_sat_interp));
        mask_common = mask_common.*mask_sat.*mask;
    end

    % SMOS BEC
    if isdaily == 1
        di = dd;
%         vari_sat = NaN;
%         while isscalar(vari_sat)
%             di = di+1;
        [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_daily('SMOS_BEC', 4, datenum(yyyy, mm, di));
%         end
    else
        [lat_sat, lon_sat, vari_sat] = load_SSS_sat_2d_monthly('SMOS_BEC', 4, yyyy, mm);
    end
    if ~isscalar(vari_sat)
        if ~exist('Fsmos')
%             [lat_sat2, lon_sat2] = meshgrid(lat_sat, lon_sat);
%             Fsmos = griddedInterpolant(lat_sat2', lon_sat2', 0.*lat_sat2');
            Fsmos = scatteredInterpolant(lat_sat(:), lon_sat(:), 0.*lat_sat(:));
        end
        Fsmos.Values = vari_sat(:);

        %vari_sat_interp = griddata(lat_sat, lon_sat, vari_sat, g.lat_rho, g.lon_rho);
        vari_sat_interp = Fsmos(g.lat_rho, g.lon_rho);
        mask_sat = double(~isnan(vari_sat_interp));
        mask_common = mask_common.*mask_sat.*mask;
    end
end

mask_common(g.h < depth_cutoff) = 0;

figure; hold on;
pcolor(g.lon_rho, g.lat_rho, mask_common);
shading flat
contour(g.lon_rho, g.lat_rho, g.h, [50 100 200], 'k')
caxis([0 1])

if isdaily == 1
    save(['mask_common_', mstr, '_', dstr, '.mat'], 'mask_common', 'depth_cutoff', 'isdaily', 'dd')
else
    save(['mask_common_', mstr, '.mat'], 'mask_common', 'depth_cutoff')
end