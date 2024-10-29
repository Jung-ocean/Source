%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS potential density
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Eastern_Bering';

exp = 'Dsm4';
vari_str = 'pden';
yyyy_all = 2019:2022;
mm = 7;
mstr = num2str(mm, '%02i');

isfill = 1;
depth = -200;
dstr = num2str(-depth);

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Load grid information
g = grd('BSf');

% Figure properties
interval = 0.2;
climit = [25.5 27.5];
num_color = diff(climit)/interval;
contour_interval = climit(1):interval:climit(end);
color = jet(num_color);
unit = '\sigma_t';

savename = 'pden';

switch map
    case 'Gulf_of_Anadyr'
        text1_lat = 65.9;
        text1_lon = -184.8;
        text2_lat = 65.9;
        text2_lon = -178;
        text_FS = 15;
    case 'Eastern_Bering'
        text1_lat = 65.7;
        text1_lon = -184.8;
        text2_lat = 65.7;
        text2_lon = -166;
        text_FS = 15;
end

figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);
% Figure title
title(t, [num2str(-depth), 'm potential density (interval = ', num2str(interval), ')'], 'FontSize', 20);
if isfill ==1
    title(t, [num2str(-depth), 'm or bottom potential density (interval = ', num2str(interval), ')'], 'FontSize', 20);
end

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    zeta = ncread(file, 'zeta')';
    
    z = zlevs(g.h,zeta,g.theta_s,g.theta_b,g.hc,g.N,'r',2);
    temp_sigma = squeeze(ncread(file, 'temp'));
    temp_sigma = permute(temp_sigma, [3 2 1]);

    salt_sigma = squeeze(ncread(file, 'salt'));
    salt_sigma = permute(salt_sigma, [3 2 1]);

    lat3d = repmat(g.lat_rho, [1, 1, g.N]);
    lat3d = permute(lat3d, [3 1 2]);
    pres = sw_pres(abs(z), lat3d);

    pden = NaN([g.N, size(g.mask_rho)]);
    for ni = 1:g.N
        salt_tmp = squeeze(salt_sigma(ni,:,:));
        temp_tmp = squeeze(temp_sigma(ni,:,:));
        pres_tmp = squeeze(pres(ni,:,:));

        pden(ni,:,:) = sw_pden_ROMS(salt_tmp, temp_tmp, pres_tmp, 0);
    end
    vari_sigma = pden - 1000;
    vari_bottom = squeeze(vari_sigma(1,:,:));
    vari = vinterp(vari_sigma,z,depth);

    if isfill == 1
        vari(isnan(vari) == 1) = vari_bottom(isnan(vari) == 1);
    end

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    contourm(g.lat_rho, g.lon_rho, g.h, [50 100 200], 'k');

%     p = pcolorm(g.lat_rho, g.lon_rho, vari_bar.*g.mask_rho./g.mask_rho); shading flat
    p = plot_contourf(g.lat_rho, g.lon_rho, vari, contour_interval, climit, color);
    plot_map(map, 'mercator', 'l')
    if yi == 4
        c = colorbar;
        c.Title.String = unit;
    end

    if strcmp(map, 'Gulf_of_Anadyr')
        textm(text1_lat, text1_lon, 'ROMS', 'FontSize', text_FS)
        textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)
    else
        title(['ROMS (', title_str, ')'])
    end
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', dstr, 'm_', mstr, '_monthly'],'-dpng');
