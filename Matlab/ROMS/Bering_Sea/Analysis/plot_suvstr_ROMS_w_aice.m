%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot ROMS suvstr with aice monthly
%
% J. Jung
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all

map = 'Gulf_of_Anadyr';

exp = 'Dsm4';
vari_str = 'suvstr';
yyyy_all = 2019:2022;
mm = 1;
mstr = num2str(mm, '%02i');

filepath = ['/data/jungjih/ROMS_BSf/Output/Multi_year/', exp, '/monthly/'];

% Load grid information
g = grd('BSf');

% Figure properties
interval_model = 40;
scale_model = 15;
skip = 1;
npts = [0 0 0 0];

color = 'jet';
climit = [0 1];
unit = '';
savename = 'suvstr_w_aice';
text1_lat = 65.9;
text1_lon = -184.8;
text2_lat = 65.9;
text2_lon = -178;
text_FS = 15;

figure;
set(gcf, 'Position', [1 200 1500 450])
t = tiledlayout(1,4);
% Figure title
title(t, ['Surface stress with aice'], 'FontSize', 20);

for yi = 1:length(yyyy_all)
    yyyy = yyyy_all(yi); ystr = num2str(yyyy);
    title_str = datestr(datenum(yyyy,mm,1), 'mmm, yyyy');

    filename = [exp, '_', ystr, mstr, '.nc'];
    file = [filepath, filename];
    aice = ncread(file, 'aice')';
    sustr = ncread(file, 'sustr')';
    svstr = ncread(file, 'svstr')';
    
    [sustr_rho,svstr_rho,lonred,latred,maskred] = uv_vec2rho(sustr,svstr,g.lon_rho,g.lat_rho,g.angle,g.mask_rho,skip,npts);

    nexttile(yi); hold on
    plot_map(map, 'mercator', 'l')
    
    p = pcolorm(g.lat_rho, g.lon_rho, aice.*g.mask_rho./g.mask_rho); shading flat
    colormap(gray)
    uistack(p, 'bottom')
    plot_map(map, 'mercator', 'l')
    caxis(climit)
    if yi == 4
        c = colorbar;
        c.Title.String = unit;
    end

    q = quiverm(g.lat_rho(1:interval_model:end, 1:interval_model:end), ...
                g.lon_rho(1:interval_model:end, 1:interval_model:end), ...
                svstr_rho(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                sustr_rho(1:interval_model:end, 1:interval_model:end).*scale_model, ...
                0);

    q(1).Color = [0 0.4471 0.7412];
    q(2).Color = [0 0.4471 0.7412];
%     q(1).Color = [0 1 1];
%     q(2).Color = [0 1 1];
    q(1).LineWidth = 2;
    q(2).LineWidth = 2;

    textm(text1_lat, text1_lon, 'sstr', 'FontSize', text_FS)
    textm(text2_lat, text2_lon, [title_str], 'FontSize', text_FS)

    qscale = quiverm(64, -184.5, 0.*scale_model, 0.1.*scale_model, 0);
    qscale(1).Color = 'r';
    qscale(2).Color = 'r';
    tscale = textm(63.5, -184.5, '0.1 N/m^2', 'Color', 'r', 'FontSize', 10);
end % yi

t.Padding = 'compact';
t.TileSpacing = 'compact';

print([savename, '_', map, '_', mstr, '_monthly'],'-dpng');