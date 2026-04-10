%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ARGO BOA salinity on the z26.7 surface
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

region = 'NE_Pacific';
[lonlim, latlim] = load_domain(region);

zsurf = 1026.7;
savename = 's26_7';

yyyy_all = 2019:2023;
mm_all = [1:12];

% ARGO
filepath_ARGO = ['/data/sdurski/Observations/ARGO/ARGO_BOA/'];

% Load grid information
g = grd('BSf');

% Figure properties
% colormap = 'redblue';
cm = load('ncview_colormaps.mat');
colormap = cm.cm_blu_red;
climit = [33.5 33.75];
interval = .01;
[color, contour_interval] = get_color(colormap, climit, interval);
unit = 'psu';

f1 = figure; hold on
set(gcf, 'Position', [1 200 800 500])
plot_map(region, 'mercator', 'l')
contourm(g.lat_rho, g.lon_rho, g.h, [200 1000], 'k');

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi);
    ystr = num2str(yyyy);

    for mi = 1:length(mm_all)
        mm = mm_all(mi);
        mstr = num2str(mm, '%02i');

        timenum_tmp = datenum(yyyy,mm,15);

        filename_ARGO = ['BOA_Argo_', ystr, '_', mstr, '.mat'];
        file_ARGO = [filepath_ARGO, filename_ARGO];
        ARGO = load(file_ARGO);

        lon = ARGO.lon-360;
        lat = ARGO.lat;
        temp = ARGO.temp;
        salt = ARGO.salt;
        p = ARGO.pres;

        lonind = find(lon(:,1) > min(lonlim)-1 & lon(:,1) < max(lonlim)+1);
        lonind = lonind';
        latind = find(lat(1,:) > min(latlim)-1 & lat(1,:) < max(latlim)+1);

        vari = NaN(size(lon));
        for i = lonind
            for j = latind

                lon_tmp = lon(i,j);
                lat_tmp = lat(i,j);
                z_tmp = gsw_z_from_p(p,lat_tmp);
                temp_tmp = squeeze(temp(i,j,:));
                salt_tmp = squeeze(salt(i,j,:));

                [SA, in_ocean] = gsw_SA_from_SP(salt_tmp,p,lon_tmp,lat_tmp);
                % Potential temperature
                pt0 = gsw_pt0_from_t(SA,temp_tmp,p);
                % Potential density
                CT = gsw_CT_from_pt(SA,pt0);
                pden_tmp = gsw_rho(SA,CT,0);

                try
                    vari(i,j) = interp1(pden_tmp, salt_tmp, zsurf);
                catch
                end
            end % j
        end % i

        p = plot_contourf([], lat, lon, vari, color, climit, contour_interval);
        if mi == 1 & yi == 1
            c = colorbar;
            c.Title.String = unit;
        end
        title(['s26.7 (', datestr(timenum_tmp, 'mmm, yyyy'), ')'], 'FontSize', 15);

        % Make gif
        gifname = [savename, '_', region, '_monthly.gif'];

        frame = getframe(f1);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if mi == 1 & yi == 1
            imwrite(imind,cm, gifname, 'gif', 'Loopcount', inf);
        else
            imwrite(imind,cm, gifname, 'gif', 'WriteMode', 'append');
        end
        delete(p)
    end % mi
end % yi