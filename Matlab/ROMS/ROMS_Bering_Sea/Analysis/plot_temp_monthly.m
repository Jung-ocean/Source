%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS temperature
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Eastern_Bering';

exp = 'Dsm4';
vari_str = 'temp';
yyyy_all = 2019:2022;
mm = 1;
mstr = num2str(mm, '%02i');

isfill = 0;
layer = 45;
if layer < 0
    dstr = num2str(-layer);
else
    dstr = num2str(layer);
end

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];
filepath_streamfunction = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/transport/streamfunction/'];

% Load grid information
g = grd('BSf');

% Figure properties
interval = 2;
climit = [-2 12];
num_color = diff(climit)/interval;
contour_interval = climit(1):interval:climit(end);
color = jet(num_color);
unit = '^oC';

savename = 'temp';

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

if layer < 0
    title(t, [num2str(-layer), 'm temperature (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);
    if isfill == 1
        title(t, [num2str(-layer), 'm or bottom temperature (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);
    end
elseif layer == 45
    title(t, ['SST (interval = ', num2str(interval), ' ', unit, ')'], 'FontSize', 20);
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
    
    if layer < 0
        vari_sigma = temp_sigma;
        vari_bottom = squeeze(vari_sigma(1,:,:));
        vari = vinterp(vari_sigma,z,layer);

        if isfill == 1
            vari(isnan(vari) == 1) = vari_bottom(isnan(vari) == 1);
        end
    else
        vari = squeeze(temp_sigma(layer,:,:));
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

if layer < 0
    print([savename, '_', map, '_', dstr, 'm_', mstr, '_monthly'],'-dpng');
else
    print([savename, '_', map, '_layer_', dstr, '_', mstr, '_monthly'],'-dpng');
end
